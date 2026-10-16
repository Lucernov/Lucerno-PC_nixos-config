# pkgs/pkg_reaper.nix
#
# Обёртка для REAPER, которая:
#   1. Переключает CPU governor в performance на время работы.
#   2. Ограничивает процесс ядрами 2..N-1 (или 0 на слабых машинах).
#   3. Возвращает governor в powersave после выхода.
#
# Используется writeShellApplication для автоматической проверки
# скрипта через shellcheck и добавления runtime-зависимостей в PATH.
#
# ВАЖНО про sudo:
#   sudo НЕ добавлен в runtimeInputs — в /nix/store бинарник sudo лежит без
#   setuid-бита, и вызов от не-root пользователя молча падает с
#   "effective uid is not 0". Используем /run/wrappers/bin/sudo — setuid-
#   враппер, создаваемый модулем security.sudo в NixOS.
#
# ВАЖНО про cpupower:
#   Используем абсолютный путь ${cpupower}/bin/cpupower через Nix-интерполяцию,
#   чтобы:
#     • вызов совпал с правилом в security.sudo.extraRules
#       (см. modules/default.nix) — важно при использовании sudo;
#     • shellcheck не ругался на неquoted-переменные (SC2086);
#     • бинарник не затенялся другим cpupower из PATH.
#
# ВАЖНО про ядра:
#   irqaffinity=0 в hardware-configuration.nix прибивает все IRQ к CPU 0.
#   Оставляем CPU 0 и 1 системе, REAPER получает ядра 2..N-1.

{ symlinkJoin
, makeWrapper
, writeShellApplication
, reaper
, cpupower
, util-linux
, coreutils
}:

let
  reaper-wrapper = writeShellApplication {
    name = "reaper";
    runtimeInputs = [
      util-linux
      coreutils
    ];
    text = ''
      export GDK_BACKEND=x11
      export WINEPREFIX="''${WINEPREFIX:-/mnt/music/MUSIC-WINE/yabridge}"

      SELF_DIR="$(cd "$(dirname "''${BASH_SOURCE[0]}")" && pwd)"

      cleanup() {
        local exit_code=$?
        /run/wrappers/bin/sudo ${cpupower}/bin/cpupower frequency-set -g powersave >/dev/null 2>&1 || true
        exit "$exit_code"
      }

      trap cleanup EXIT
      trap 'exit 130' INT
      trap 'exit 143' TERM
      trap 'exit 129' HUP

      # Переключаем governor в performance перед запуском REAPER
      # для минимальной задержки аудио.
      /run/wrappers/bin/sudo ${cpupower}/bin/cpupower frequency-set -g performance >/dev/null 2>&1 || true

      # Определяем доступные ядра. CPU 0 занят IRQ (irqaffinity=0),
      # CPU 1 оставляем системе под фоновые процессы.
      NPROC=$(nproc)
      if [ "$NPROC" -gt 2 ]; then
        CORES="2-$((NPROC - 1))"
      else
        CORES="0"
      fi

      # Запускаем REAPER на выбранных ядрах.
      taskset -c "$CORES" "$SELF_DIR/.reaper-unwrapped" "$@"

      # Governor восстановится через trap EXIT (cleanup).
    '';
  };
in
symlinkJoin {
  name = "reaper-wrapped";
  paths = [ reaper ];
  nativeBuildInputs = [ makeWrapper ];
  postBuild = ''
    mv $out/bin/reaper $out/bin/.reaper-unwrapped
    cp ${reaper-wrapper}/bin/reaper $out/bin/reaper
  '';
}
