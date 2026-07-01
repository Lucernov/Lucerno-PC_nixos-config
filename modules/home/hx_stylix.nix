{ inputs, ... }:

{
  stylix = {
    base16Scheme = "${inputs.stylix.inputs.tinted-schemes}/base16/nord.yaml";
    targets.kitty.enable = true;                # явно включаем поддержку Kitty
    opacity.terminal = 0.95;                    # уровень прозрачности терминала
  };
}
