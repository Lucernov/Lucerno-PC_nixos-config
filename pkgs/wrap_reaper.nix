# pkgs/wrap_reaper.nix
#
# Обёртка для REAPER, которая:
#   1. Переключает CPU governor в performance на время работы.
#   2. Ограничивает процесс ядрами 2-11 (только P-ядра i5-13400F).
#   3. Возвращает governor в powersave после выхода.
#
# Используется writeShellApplication для автоматической проверки
# скрипта через shellcheck и добавления runtime-зависимостей в PATH
#
# Про sudo:
#   sudo НЕ добавлен в runtimeInputs — в /nix/store бинарник sudo лежит без
#   setuid-бита, и вызов от не-root пользователя молча падает с
#   "effective uid is not 0". Используем /run/wrappers/bin/sudo — setuid-
#   враппер, создаваемый модулем security.sudo в NixOS
#
# Про cpupower:
#   Используем абсолютный путь ${cpupower}/bin/cpupower через Nix-интерполяцию,
#   чтобы:
#     • вызов совпал с правилом в security.sudo.extraRules
#       (см. modules/default.nix) — важно при использовании sudo;
#     • shellcheck не ругался на неquoted-переменные (SC2086);
#     • бинарник не затенялся другим cpupower из PATH
#
# Про ядра (i5-13400F):
#   6 P-ядер с HT (CPU 0-11) + 4 E-ядра (CPU 12-15) = 16 логических CPU
#     • CPU 0     — IRQ (irqaffinity=0), системе
#     • CPU 1     — второй поток первого P-ядра, системе
#     • CPU 2-11  — P-ядра, отдаём REAPER
#     • CPU 12-15 — E-ядра, системе

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

      # CPU 0-1 пропуск (IRQ + системный поток P-ядра 0)
      # CPU 12-15 прпууск (E-ядра)
      taskset -c 2-11 "$SELF_DIR/.reaper-unwrapped" "$@"

      # Governor восстановится через trap EXIT (cleanup)
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
