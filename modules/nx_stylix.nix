# modules/nx_stylix.nix
{ config, pkgs, lib, ... }:

let myLib = import ../lib.nix; in

{
  # Объявляем недостающую опцию для stylix GNOME
#  options.services.displayManager.generic = lib.mkOption {
#    type = lib.types.attrs;
#    default = {};
#    description = "Legacy option required by stylix GNOME module";
#  };

  # Конфигурация stylix
  config = {
    stylix = {
      enable = true;
      image = myLib.wallpaperPath;
      polarity = "dark";
      base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-medium.yaml";
#      targets = {
#        gnome.enable = false;   # отключаем GNOME
#      };
    };
  };
}
