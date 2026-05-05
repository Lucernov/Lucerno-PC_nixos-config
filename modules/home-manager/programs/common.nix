{ pkgs, ... }:
{
  home.packages = with pkgs; [
    nh
    lsof
    # KDE приложения
    kdePackages.kde-gtk-config
    kdePackages.ktorrent
    kdePackages.kdenlive
    #kdePackages.yakuake
    kdePackages.kcalc

    # ГРАФИКА
    pinta
    krita
    gimp
    inkscape
    blender
    upscaler

    # ИГРЫ
    (bottles.override { removeWarningPopup = true; })
    goverlay
    lutris
    heroic

    # ИНТЕРНЕТ
    parabolic
    discord
    telegram-desktop

    # МУЛЬТИМЕДИА
    vlc
    qmmp

    # МУЗЫКА
    yabridge
    yabridgectl
    winetricks                # для настройки префиксов
    coppwr


    vital                     # синтезатор FM
    surge-xt                  # синтезатор FM
    geonkick                  # синтезатор барабанов
    drumgizmo               # сэмплер барабанов (0.9.20)
    neural-amp-modeler-lv2
    dragonfly-reverb
    fretboard


    # ОФИС

    # ВСЯКОЕ
    bat      # аналог cat с подсветкой синтаксиса
    btop
    mission-center
    fastfetch
    nix-tree

    # Minion обёртка
  (writeShellScriptBin "minion" ''
    export JAVA_TOOL_OPTIONS="-Dprism.lcdtext=false -Dprism.text=t2k"
    exec ${pkgs.minion}/bin/minion "$@"
  '')
  ] ++ (with pkgs-unstable; [
    # из нестабильного
    wineWow64Packages.staging
    reaper
    reaper-sws-extension
    reaper-reapack-extension
    kitty
  ]);
}
