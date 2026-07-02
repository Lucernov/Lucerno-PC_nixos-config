# Модуль настройки темы оформления (stylix) для всей системы: цвета, обои, темы приложений
{ pkgs, myLib, ... }:

{

    stylix = {
      enable = true;                                                                      # Включает глобальное управление темами через stylix
      image = myLib.wallpaperPath;                                                        # Путь к изображению для обоев рабочего стола и экрана входа
      polarity = "dark";                                                                  # Цветовая направленность: "dark" (тёмная) или "light" (светлая)
      # base16Scheme = "${pkgs.base16-schemes}/share/themes/nord.yaml";                     # Активная цветовая схема в формате base16 (Catppuccin Mocha)
      base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";         # Активная цветовая схема в формате base16 (Catppuccin Mocha)
    };

}
