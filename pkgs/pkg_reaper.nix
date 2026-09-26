# pkgs/reaper.nix
{ symlinkJoin, reaper, cpupower }:

symlinkJoin {
  name = "reaper-wrapped";
  paths = [ reaper ];
  postBuild = ''
    # Перемещаем оригинальный бинарник
    mv $out/bin/reaper $out/bin/.reaper-unwrapped
    # Создаём новый скрипт-обёртку
    cat > $out/bin/reaper <<EOF
    #!/bin/sh
    export GDK_BACKEND=x11
    export WINEPREFIX="/mnt/music/MUSIC-WINE/yabridge"

    # Устанавливаем governor в performance перед запуском REAPER (для минимальной задержки аудио)
    ${cpupower}/bin/cpupower frequency-set -g performance > /dev/null 2>&1

    # Запускаем REAPER
    taskset -c 2-11 $out/bin/.reaper-unwrapped "\$@"

    # После завершения REAPER возвращаем governor в powersave (системный default NixOS - "cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor")
    ${cpupower}/bin/cpupower frequency-set -g powersave > /dev/null 2>&1
    EOF
    chmod +x $out/bin/reaper
  '';
}
