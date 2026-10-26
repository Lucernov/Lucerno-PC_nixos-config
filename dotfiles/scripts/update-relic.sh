#!/usr/bin/env bash
# update-relic.sh — обновление пакета relic-clap через GitHub Releases
#
# Использование:
#   update-relic.sh [path/to/Relic-Linux-Folders-X.Y.Z.zip] [опции]
#
# Без аргумента — берёт самый свежий Relic-Linux-Folders-*.zip из /mnt/archiv/TEMP/.
#
# Опции:
#   --check        только сверить набор .clap, ничего не публиковать
#   --dry-run      показать шаги, ничего не делать
#   --force        пересоздать релиз, если тег уже существует
#   --no-commit    не коммитить pkg_Relic.nix (только правки на диске)
#   --push         закоммитить и запушить (по умолчанию только commit)
#   --build        после релиза собрать nix build .#relic-clap (включает --wait-cdn)
#   --wait-cdn     после релиза ждать, пока CDN отдаст 200 (таймаут 3 мин)
#
# Переменные окружения:
#   REPO_ROOT_OVERRIDE   — путь к репозиторию (по умолчанию $HOME/nixos-config)
#   TEMP_DIR_OVERRIDE    — куда смотреть за zip (по умолчанию /mnt/archiv/TEMP)
#   GH_TOKEN             — токен GitHub (по умолчанию из /run/agenix/github-token)
#
# Требования: unzip, zstd, tar, nix-hash, gh (GitHub CLI), bash.

set -euo pipefail

# ============ Конфиг ============
REPO_ROOT="${REPO_ROOT_OVERRIDE:-$HOME/nixos-config}"
TEMP_DIR="${TEMP_DIR_OVERRIDE:-/mnt/archiv/TEMP}"
PKG_FILE="$REPO_ROOT/pkgs/pkg_Relic.nix"
STAGE_DIR="/tmp/relic-stage"

# Префикс тега релиза и имени файла
RELEASE_PREFIX="relic-clap"
ASSET_PREFIX="Relic-Linux-CLAP"

# Ожидаемый набор .clap. Обновлять при изменениях у upstream.
EXPECTED_CLAP=(
  RF-16VU RF-1B RF-2A RF-55A RF-56 RF-67 RF-73 RF-76
  RF-A80 RF-AT12 RF-E RF-EQ1-A RF-MQ-5
)

# ============ Разбор аргументов ============
CHECK_ONLY=0
DRY_RUN=0
FORCE=0
NO_COMMIT=0
DO_PUSH=0
DO_BUILD=0
WAIT_CDN=0
ZIP_ARG=""
for arg in "$@"; do
  case "$arg" in
    --check)     CHECK_ONLY=1 ;;
    --dry-run)   DRY_RUN=1 ;;
    --force)     FORCE=1 ;;
    --no-commit) NO_COMMIT=1 ;;
    --push)      DO_PUSH=1 ;;
    --build)     DO_BUILD=1; WAIT_CDN=1 ;;
    --wait-cdn)  WAIT_CDN=1 ;;
    -h|--help)
      sed -n '3,26p' "$0" | sed 's/^# \?//'
      exit 0
      ;;
    -*) echo "Неизвестный флаг: $arg" >&2; exit 1 ;;
    *)  ZIP_ARG="$arg" ;;
  esac
done

# ============ Проверка окружения ============
if [[ ! -f "$PKG_FILE" ]]; then
  echo "❌ Деривация не найдена: $PKG_FILE" >&2
  echo "   Проверьте REPO_ROOT_OVERRIDE или что репозиторий в $HOME/nixos-config" >&2
  exit 1
fi

# ============ Trap ============
cleanup() {
  local code=$?
  if [[ $code -eq 0 && $DRY_RUN -eq 0 ]]; then
    rm -rf "$STAGE_DIR"
  elif [[ $code -ne 0 ]]; then
    echo "⚠️  Стейджинг сохранён для отладки: $STAGE_DIR" >&2
  fi
}
trap cleanup EXIT

# ============ Шаг 1: найти zip ============
if [[ -n "$ZIP_ARG" ]]; then
  ZIP="$ZIP_ARG"
else
  if [[ ! -d "$TEMP_DIR" ]]; then
    echo "❌ Каталог $TEMP_DIR не существует (диск /mnt/archiv не смонтирован?)" >&2
    exit 1
  fi
  ZIP=$(find "$TEMP_DIR" -maxdepth 1 -name 'Relic-Linux-Folders-*.zip' \
          -printf '%T@ %p\n' 2>/dev/null | sort -rn | head -1 | cut -d' ' -f2- || true)
fi

if [[ -z "${ZIP:-}" || ! -f "$ZIP" ]]; then
  echo "❌ Zip не найден: ${ZIP:-<пусто>}" >&2
  echo "   Положите Relic-Linux-Folders-X.Y.Z.zip в $TEMP_DIR" >&2
  echo "   или передайте путь первым аргументом." >&2
  exit 1
fi
echo "📦 Исходник: $ZIP"

# ============ Шаг 2: определить версию ============
TOP=$(unzip -Z1 "$ZIP" | grep -m1 -oE '^[^/]+/CLAP/' | cut -d/ -f1 || true)
if [[ -z "$TOP" ]]; then
  echo "❌ В zip нет каталога */CLAP/" >&2
  exit 1
fi
VERSION=$(echo "$TOP" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1 || true)
if [[ -z "$VERSION" ]]; then
  echo "❌ Не удалось определить версию из «$TOP»" >&2
  exit 1
fi
echo "🔖 Версия: $VERSION  (префикс в zip: «$TOP»)"

# ============ Шаг 3: определить owner/repo для URL ============
if [[ -n "${GITHUB_REPO_SLUG:-}" ]]; then
  REPO_SLUG="$GITHUB_REPO_SLUG"
else
  remote_url=$(git -C "$REPO_ROOT" remote get-url origin 2>/dev/null || true)
  if [[ -z "$remote_url" ]]; then
    echo "❌ Не удалось определить git remote origin в $REPO_ROOT" >&2
    echo "   Установите GITHUB_REPO_SLUG=owner/repo" >&2
    exit 1
  fi
  # https://github.com/O/R.git, git@github.com:O/R.git, ssh://git@host:port/O/R.git
  # Сначала отрезаем .git$, потом берём последние две компоненты пути.
  REPO_SLUG=$(echo "$remote_url" \
    | sed -E 's#\.git$##' \
    | sed -E 's#.*[:/]([^/]+/[^/]+)$#\1#')
fi
echo "🏷️  Репозиторий: $REPO_SLUG"

RELEASE_TAG="${RELEASE_PREFIX}-${VERSION}"
ASSET_NAME="${ASSET_PREFIX}-${VERSION}.tar.zst"
RELEASE_URL="https://github.com/${REPO_SLUG}/releases/download/${RELEASE_TAG}/${ASSET_NAME}"

# ============ Шаг 4: извлечь CLAP ============
rm -rf "$STAGE_DIR"
mkdir -p "$STAGE_DIR"
echo "🗜️  Извлекаю ${TOP}/CLAP/..."
unzip -q "$ZIP" "${TOP}/CLAP/*" -d "$STAGE_DIR"

if [[ ! -d "$STAGE_DIR/${TOP}/CLAP" ]]; then
  echo "❌ После распаковки нет $STAGE_DIR/${TOP}/CLAP/" >&2
  exit 1
fi

mv "$STAGE_DIR/${TOP}/CLAP" "$STAGE_DIR/CLAP"
rm -rf "$STAGE_DIR/${TOP}"

if ! compgen -G "$STAGE_DIR/CLAP/*.clap" >/dev/null; then
  echo "❌ В CLAP/ нет .clap-файлов" >&2
  exit 1
fi

# ============ Шаг 5: сверить набор ============
actual=$(cd "$STAGE_DIR/CLAP" && ls *.clap | sed 's/\.clap$//' | sort)
expected=$(printf '%s\n' "${EXPECTED_CLAP[@]}" | sort)

if [[ "$actual" != "$expected" ]]; then
  echo "⚠️  Набор .clap отличается от EXPECTED_CLAP:"
  diff <(echo "$expected") <(echo "$actual") || true
  if [[ "$FORCE" -eq 1 ]]; then
    echo "   --force задан, продолжаю."
  else
    read -p "Продолжить? [y/N] " ans
    [[ "$ans" =~ ^[Yy]$ ]] || { echo "Отмена."; exit 1; }
  fi
else
  echo "✅ Набор .clap совпадает (${#EXPECTED_CLAP[@]} файлов)"
fi

if [[ "$CHECK_ONLY" -eq 1 ]]; then
  echo
  echo "🟢 --check: zip валиден, набор совпадает. Ничего не сделано."
  exit 0
fi

# ============ Шаг 6: перепаковать ============
TARGET="$STAGE_DIR/$ASSET_NAME"

if [[ "$DRY_RUN" -eq 1 ]]; then
  echo
  echo "🟡 --dry-run: дальнейшие шаги НЕ выполняются:"
  echo "   tar+ zstd → $TARGET"
  echo "   nix-hash → SRI-хеш"
  echo "   gh release create $RELEASE_TAG --title ... --notes ... $TARGET"
  echo "   sed по $PKG_FILE: version=$VERSION, url=$RELEASE_URL, hash=..."
  [[ "$NO_COMMIT" -eq 1 ]] || echo "   git add $PKG_FILE && git commit"
  [[ "$DO_PUSH" -eq 0 ]] || echo "   git push"
  [[ "$DO_BUILD" -eq 0 ]] || echo "   nix build .#relic-clap -L"
  exit 0
fi

echo "🗜️  Перепаковываю в tar.zst (zstd --ultra -22), ~1.5 мин..."
(cd "$STAGE_DIR" && \
  tar --sort=name --mtime='@0' --owner=0 --group=0 --numeric-owner \
      -c CLAP | zstd --ultra -22 -T0 -q -c > "$TARGET")

SIZE=$(du -h "$TARGET" | cut -f1)
SIZE_BYTES=$(stat -c %s "$TARGET")
echo "📦 Готово: $TARGET ($SIZE)"

if [[ "$SIZE_BYTES" -lt 50000000 || "$SIZE_BYTES" -gt 300000000 ]]; then
  echo "⚠️  Размер подозрительный ($SIZE_BYTES байт)." >&2
fi

# Sanity-check структуры
content=$(tar -tf "$TARGET")
if ! grep -qE '^CLAP/$' <<<"$content"; then
  echo "❌ Архив не содержит CLAP/ на верхнем уровне" >&2
  exit 1
fi
count=$(grep -c '\.clap$' <<<"$content")
if [[ "$count" -ne "${#EXPECTED_CLAP[@]}" ]]; then
  echo "❌ В архиве $count .clap, ожидалось ${#EXPECTED_CLAP[@]}" >&2
  exit 1
fi

# ============ Шаг 7: хеш ============
HASH=$(nix-hash --type sha256 --flat --sri "$TARGET")
echo "🔑 Хеш: $HASH"

# ============ Шаг 8: подготовить gh и токен ============
if ! command -v gh &>/dev/null; then
  echo "❌ gh (GitHub CLI) не найден в PATH" >&2
  echo "   Установите: nix profile install nixpkgs#gh" >&2
  echo "   или запустите скрипт из nix shell nixpkgs#gh" >&2
  exit 1
fi

if [[ -z "${GH_TOKEN:-}" ]]; then
  if [[ -r /run/agenix/github-token ]]; then
    GH_TOKEN=$(grep -oE 'ghp_[A-Za-z0-9]+|github_pat_[A-Za-z0-9_]+' /run/agenix/github-token | head -1 || true)
    export GH_TOKEN
  fi
fi
if [[ -z "${GH_TOKEN:-}" ]]; then
  echo "❌ GH_TOKEN не задан и не удалось прочитать /run/agenix/github-token" >&2
  echo "   export GH_TOKEN=ghp_..." >&2
  exit 1
fi

if ! gh auth status &>/dev/null; then
  echo "❌ gh не авторизован. Проверьте GH_TOKEN:" >&2
  gh auth status 2>&1 | sed 's/^/   /' >&2
  exit 1
fi

# ============ Шаг 9: существующий релиз ============
if gh release view "$RELEASE_TAG" &>/dev/null; then
  echo "⚠️  Релиз $RELEASE_TAG уже существует"
  if [[ "$FORCE" -eq 1 ]]; then
    echo "   --force задан, удаляю."
    gh release delete "$RELEASE_TAG" --yes --cleanup-tag
  else
    read -p "Удалить и пересоздать? [y/N] " ans
    if [[ "$ans" =~ ^[Yy]$ ]]; then
      gh release delete "$RELEASE_TAG" --yes --cleanup-tag
    else
      echo "Отмена."
      exit 1
    fi
  fi
fi

# ============ Шаг 10: создать релиз ============
echo "🚀 Создаю релиз $RELEASE_TAG (загрузка $SIZE)..."
gh release create "$RELEASE_TAG" \
  --title "Relic CLAP $VERSION" \
  --notes "Relic Free Audio Plugin Suite — ${#EXPECTED_CLAP[@]} CLAP plugins.

Обновление из архива апстрима \`${ZIP##*/}\` — извлечены только CLAP-плагины, VST3 и документация не включены. Перепаковано в tar.zst (zstd --ultra -22), воспроизводимо." \
  "$TARGET"

echo "✅ Релиз создан: https://github.com/${REPO_SLUG}/releases/tag/${RELEASE_TAG}"

# ============ Шаг 11: дождаться CDN ============
if [[ "$WAIT_CDN" -eq 1 ]]; then
  echo "⏳ Жду, пока CDN отдаст $RELEASE_URL..."
  deadline=$(( $(date +%s) + 180 ))
  while (( $(date +%s) < deadline )); do
    code=$(curl -sIL -o /dev/null -w '%{http_code}' "$RELEASE_URL" || echo 000)
    if [[ "$code" == "200" ]]; then
      echo "✅ CDN готов"
      break
    fi
    sleep 5
  done
  if [[ "$code" != "200" ]]; then
    echo "⚠️  CDN не отдал 200 за 3 минуты (последний код: $code)" >&2
    echo "   Попробуйте nix build позже — объект в S3 уже точно есть." >&2
  fi
fi

# ============ Шаг 12: пропатчить деривацию ============
echo "✏️  Обновляю $PKG_FILE..."
cp "$PKG_FILE" "$PKG_FILE.bak"

sed -i -E \
  -e "s|^([[:space:]]*version = )\"[^\"]*\"|\\1\"$VERSION\"|" \
  -e "s|^([[:space:]]*url = )\"[^\"]*\"|\\1\"$RELEASE_URL\"|" \
  -e "s|^([[:space:]]*hash = )\"sha256-[^\"]*\"|\\1\"$HASH\"|" \
  "$PKG_FILE"

echo
echo "=== diff $PKG_FILE ==="
diff -u "$PKG_FILE.bak" "$PKG_FILE" || true
rm -f "$PKG_FILE.bak"

# ============ Шаг 13: commit / push ============
if [[ "$NO_COMMIT" -eq 0 ]]; then
  cd "$REPO_ROOT"
  git add "$PKG_FILE"
  git commit -m "${RELEASE_PREFIX}: ${VERSION} через GitHub Releases"
  echo "✅ Закоммичено: ${RELEASE_PREFIX}: ${VERSION}"

  if [[ "$DO_PUSH" -eq 1 ]]; then
    git push
    echo "✅ Запушено"
  fi
fi

# ============ Шаг 14: build ============
if [[ "$DO_BUILD" -eq 1 ]]; then
  cd "$REPO_ROOT"
  echo "🔨 nix build .#relic-clap -L"
  nix build .#relic-clap -L
  ls -la result/lib/clap/
fi

# ============ Финал ============
echo
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Готово."
echo "  📦 Релиз:       https://github.com/${REPO_SLUG}/releases/tag/${RELEASE_TAG}"
echo "  🔗 URL в nix:   $RELEASE_URL"
echo "  🔑 Хеш:         $HASH"
if [[ "$NO_COMMIT" -eq 0 && "$DO_PUSH" -eq 0 ]]; then
  echo "  📝 Дальше:      git push"
fi
if [[ "$DO_BUILD" -eq 0 ]]; then
  echo "  🔨 Проверка:    nix build .#relic-clap -L"
fi
echo "  🚀 Установка:   sudo nixos-rebuild switch --flake .#Lucerno-PC"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
