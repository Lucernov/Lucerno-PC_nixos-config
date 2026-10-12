# pkgs/pkg_reaper.nix
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

    # Фиксируем масштаб UI. libSwell (UI-библиотека REAPER) читает GDK_SCALE
    # и GDK_DPI_SCALE, а не ui_scale из reaper.ini. Без явного экспорта
    # KDE может навязать своё значение через .desktop-launcher.
    export GDK_SCALE=1.45
    export GDK_DPI_SCALE=1

    export WINEPREFIX="/mnt/music/MUSIC-WINE/yabridge"

    # Ловим сигналы завершения и восстанавливаем governor
    restore_governor() {
      sudo ${cpupower}/bin/cpupower frequency-set -g powersave > /dev/null 2>&1
      exit 0
    }
    trap restore_governor TERM INT HUP

    # Устанавливаем governor в performance перед запуском REAPER (для минимальной задержки аудио)
    # sudo нужен, потому что cpupower пишет в /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor — доступ только у root
    # Правило NOPASSWD для этой команды задано в modules/default.nix (security.sudo.extraRules)
    sudo ${cpupower}/bin/cpupower frequency-set -g performance > /dev/null 2>&1

    # Запускаем REAPER на ядрах 2-11: пропускаем CPU 0-1 (там системные прерывания, см. kernelParams irqaffinity=0)
    taskset -c 2-11 $out/bin/.reaper-unwrapped "\$@"

    # После завершения REAPER возвращаем governor в powersave (системный default NixOS)
    sudo ${cpupower}/bin/cpupower frequency-set -g powersave > /dev/null 2>&1
EOF
    chmod +x $out/bin/reaper
  '';
}
