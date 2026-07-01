{ inputs, ... }:

{
  # Правильный путь к схеме Nord внутри репозитория tinted-schemes
  stylix.base16Scheme = "${inputs.stylix.inputs.tinted-schemes}/base16/nord.yaml";

  # Прозрачность фона терминала
  stylix.opacity.terminal = 0.95;
}
