{ pkgs, ... }:
{
  stylix = {
    base16Scheme = "${pkgs.base16-schemes}/share/themes/nord.yaml";
    targets.kitty = {
      enable = true;
      opacity = 0.80;
    };
  };
}
