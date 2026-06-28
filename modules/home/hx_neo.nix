{ config, pkgs, ... }:

{
  # Устанавливаем neo (если он есть в nixpkgs, но его может не быть)
  # Если neo нет в nixpkgs, можно установить через другие способы.
  # home.packages = with pkgs; [ neo ];

  # Создаём файл цветов для прозрачного фона
  xdg.configFile."neo/transparent.colors".text = ''
    // Использовать системный цвет фона (прозрачный)
    -1
    2                       # Цвет символов (2 — зелёный)
  '';

  # Алиас для запуска neo с этим файлом
  home.shellAliases = {
    neo = "neo --colorfile ${config.xdg.configHome}/neo/transparent.colors";
  };
}
