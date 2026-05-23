# modules/nx_stylix.nix
{ config, pkgs, lib, ... }:

let myLib = import ../lib.nix; in

{
  config = {
    stylix = {
      enable = true;
      image = myLib.wallpaperPath;
      polarity = "dark";
      base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-medium.yaml";

      targets = {
        kde.enable = true;        # KDE Plasma 6 (рабочий стол)
        sddm.enable = true;        # SDDM (экран входа)
        gnome.enable = false;        # Отключаем GNOME
      };
    };
  };
}
