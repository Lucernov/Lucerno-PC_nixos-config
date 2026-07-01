{ inputs, ... }:

{
  stylix = {
    #base16Scheme = "${pkgs.base16-schemes}/share/themes/nord.yaml";
    base16Scheme = "${inputs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
    targets.kitty.enable = true;
    opacity.terminal = 0.80;
  };
}
