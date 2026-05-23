# modules/nx_stylix.nix
{ config, pkgs, lib, ... }:

let myLib = import ../lib.nix; in
{
  stylix = {
    enable = true;
    image = myLib.wallpaperPath;
    polarity = "dark";             # "light" или "dark"
    base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
  };
}
