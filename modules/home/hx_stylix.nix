{ inputs, ... }:

{
  # Указываем Stylix использовать схему Nord
  stylix.base16Scheme = "${inputs.stylix.inputs.tinted-schemes}/share/themes/nord.yaml";

  # Возвращаем прозрачность фона терминала
  stylix.opacity.terminal = 0.95;
}
