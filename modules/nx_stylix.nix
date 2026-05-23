# modules/nx_stylix.nix
{ config, pkgs, lib, myLib, ... }:

{
  config = {
    stylix = {
      enable = true;
      image = myLib.wallpaperPath;
      polarity = "dark";
      #base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-medium.yaml";
      base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
    };
  };
}
