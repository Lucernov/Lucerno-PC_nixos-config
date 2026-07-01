{ inputs, pkgs, ... }:
{
  stylix = {
    base16Scheme = "${pkgs.base16-schemes}/share/themes/nord.yaml";
    targets.kitty.enable = true;
    opacity.terminal = 0.95;
  };
}
