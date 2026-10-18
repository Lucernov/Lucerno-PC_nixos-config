# pkgs/pkg_Triple-Cheese.nix
#
# TripleCheese — бесплатный комб-фильтровый синтезатор от u-he (только VST3).
# Апстрим: https://u-he.com/products/triplecheese/
#
# ─────────────────────────────────────────────────────────────────────────
# ПОЧЕМУ ТОЛЬКО VST3, БЕЗ CLAP
# ─────────────────────────────────────────────────────────────────────────
# В install.sh самого u-he есть явный список продуктов, для которых
# CLAP не собирается:
#
#   SUPPORT_CLAP=0 для TripleCheese, Uhbik, Podolski, Protoverb,
#                    BazilleCM, ZebraCM
#
# То есть CLAP-версии TripleCheese НЕ СУЩЕСТВУЕТ. Если скопировать
# TripleCheese.64.so под именем TripleCheese.clap, REAPER его не
# найдёт — в файле нет символа clap_entry. Проверка:
#   nm -D TripleCheese.clap | grep clap_entry    → пусто
#
# ─────────────────────────────────────────────────────────────────────────
# ПОЧЕМУ АРХИВ, А НЕ ОРИГИНАЛЬНЫЙ УСТАНОВЩИК u-he
# ─────────────────────────────────────────────────────────────────────────
# u-he-плагины при работе ПИШУТ в свои же файлы:
#   • ~/.u-he/TripleCheese/       — настройки, последний пресет, кэш браузера
#   • свой же TripleCheese.so     — при инициализации
# В /nix/store эти файлы read-only → плагин падает с SIGABRT при загрузке.
#
# РЕШЕНИЕ: я один раз разложил плагин по домашним папкам, выставил chmod u+w
# , убедился, что он работает, и упаковал РЕЗУЛЬТАТ в архив.
# Деривация просто распаковывает этот архив в $out. Раскладка по домашним папкам
# делается скриптом из passthru.installScript, который вызывается через
# activationScripts в modules/nx_audio.nix.
#
# ─────────────────────────────────────────────────────────────────────────
# ОБНОВЛЕНИЕ ПРИ НОВОЙ ВЕРСИИ TRIPLECHEESE
# ─────────────────────────────────────────────────────────────────────────
#  1. Скачать новый архив с https://u-he.com/products/triplecheese/
#  2. Удалить старую версию из дома:
#       rm -rf ~/.u-he/TripleCheese ~/.vst3/TripleCheese.vst3
#  3. Распаковать новый архив, скопировать по домашним путям, chmod u+w:
#       tar -xf TripleCheese_*.tar.xz -C /tmp/
#       cp -r /tmp/TripleCheese-*/TripleCheese            ~/.u-he/
#       mkdir -p ~/.vst3/TripleCheese.vst3/Contents/x86_64-linux
#       cp /tmp/TripleCheese-*/TripleCheese/TripleCheese.64.so \
#          ~/.vst3/TripleCheese.vst3/Contents/x86_64-linux/TripleCheese.so
#       chmod -R u+w ~/.u-he/TripleCheese ~/.vst3/TripleCheese.vst3
#  4. Проверить, что REAPER видит плагин и он открывается.
#  5. Пересобрать архив:
#       rm -rf /tmp/tc-writable
#       mkdir -p /tmp/tc-writable/{u-he,vst3}
#       cp -r ~/.u-he/TripleCheese       /tmp/tc-writable/u-he/
#       cp -r ~/.vst3/TripleCheese.vst3  /tmp/tc-writable/vst3/
#       cd /tmp/tc-writable
#       tar -c u-he vst3 | xz -9e -T0 -c > \
#         ~/nixos-config/dotfiles/repo/TripleCheese-writable.tar.xz
#  6. Обновить version ниже, git add архив (уже через lfs),
#     пересчитать хеш через `nix store prefetch-file` и обновить его в src ниже.

{ lib
, stdenv
, fetchurl
, xz
, writeShellScript
}:

let
  # ───────────────────────────────────────────────────────────────────────
  # Установочный скрипт (для activationScripts в modules/nx_audio.nix)
  # ───────────────────────────────────────────────────────────────────────
  # Принимает 3 аргумента:
  #   1. SRC       — путь к деривации (где лежат u-he/, vst3/)
  #   2. USER_HOME — домашняя папка пользователя (например /home/lucerno)
  #   3. USER_NAME — имя пользователя (например lucerno)
  #
  # Идемпотентен: если папка уже существует — не трогает.
  # Запускается от root (через activationScripts), поэтому делает chown/chmod.
  installScript = writeShellScript "install-triplecheese" ''
    set -e

    SRC="''${1:?usage: install-triplecheese <src> <user-home> <user-name>}"
    USER_HOME="''${2:?usage: install-triplecheese <src> <user-home> <user-name>}"
    USER_NAME="''${3:?usage: install-triplecheese <src> <user-home> <user-name>}"

    UHE_DIR="$USER_HOME/.u-he/TripleCheese"
    VST3_DIR="$USER_HOME/.vst3/TripleCheese.vst3"

    if [ ! -d "$UHE_DIR" ]; then
      mkdir -p "$(dirname "$UHE_DIR")"
      cp -r "$SRC/u-he/TripleCheese" "$UHE_DIR"
      chmod -R u+w "$UHE_DIR"
      chown -R "$USER_NAME:$USER_NAME" "$UHE_DIR"
      echo "✅ TripleCheese: $UHE_DIR создан"
    fi

    if [ ! -d "$VST3_DIR" ]; then
      mkdir -p "$(dirname "$VST3_DIR")"
      cp -r "$SRC/vst3/TripleCheese.vst3" "$VST3_DIR"
      chmod -R u+w "$VST3_DIR"
      chown -R "$USER_NAME:$USER_NAME" "$VST3_DIR"
      echo "✅ TripleCheese: $VST3_DIR создан"
    fi
  '';
in

stdenv.mkDerivation (finalAttrs: {
  pname = "triplecheese";
  version = "1.3.0.12092";

  # Архив теперь берется напрямую с GitHub Media (через LFS-домен).
  # Это позволяет собирать пакет даже тем, кто просто подключает наш флейк.
  # Структура архива:
  #   u-he/TripleCheese/         → ~/.u-he/TripleCheese
  #   vst3/TripleCheese.vst3/    → ~/.vst3/TripleCheese.vst3
  src = fetchurl {
    url = "https://media.githubusercontent.com/media/Lucernov/Lucerno-PC_nixos-config/main/dotfiles/repo/TripleCheese-writable.tar.xz";
    hash = "sha256-+QPk8XMkUeUqn7wBp9UMpwQleT2y4f206I7M0co4DQQ=";
  };

  nativeBuildInputs = [ xz ];

  dontBuild = true;
  dontConfigure = true;
  dontPatch = true;
  dontStrip = true;
  dontFixup = true;
  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    tar -xf $src -C $out

    # ── Fail-safe: проверяем, что структура архива ожидаемая ──
    for d in u-he/TripleCheese vst3/TripleCheese.vst3; do
      if [ ! -e "$out/$d" ]; then
        echo "ERROR: $d отсутствует в архиве TripleCheese-writable.tar.xz"
        echo "Содержимое $out:"
        ls -laR "$out" | head -50
        exit 1
      fi
    done

    runHook postInstall
  '';

  passthru = {
    inherit installScript;
  };

  meta = with lib; {
    description = "TripleCheese — comb-filter synthesizer from u-he (VST3)";
    homepage = "https://u-he.com/products/triplecheese/";
    license = licenses.unfreeRedistributable;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ sourceTypes.binaryNativeCode ];
  };
})
