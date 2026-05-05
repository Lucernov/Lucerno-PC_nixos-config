{ pkgs, pkgs-unstable, ... }:
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

    # ИНТЕРНЕТ
    parabolic
    discord
    telegram-desktop

    # МУЛЬТИМЕДИА
    vlc
    qmmp

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
    #kitty
  ]);
}
