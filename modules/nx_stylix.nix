# modules/nx_stylix.nix
{ config, pkgs, lib, ... }:

let myLib = import ../lib.nix; in
{
  stylix = {
    enable = true;
    image = myLib.wallpaperPath;
    polarity = "dark";             # "light" или "dark"
    base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-medium.yaml";
    targets.gnome.enable = false;
    stylix.targets.gnome.enable = lib.mkForce false;
    targets = {
      generic.enable = true;      # Отключаем настройку generic display manager
      sddm.enable = true;          # Включаем явную поддержку SDDM
    };
  };

    options.services.displayManager.generic = lib.mkOption {
    type = lib.types.attrs;
    default = {};
    description = "Legacy option required by stylix GNOME module";
  };

}
