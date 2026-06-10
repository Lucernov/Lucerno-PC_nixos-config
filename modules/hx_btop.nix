{ config, pkgs, ... }:

{
  # Настраиваем btop декларативно
  programs.btop = {
    enable = true;
    settings = {
      color_theme = "adapta";          # просто имя
      save_config_on_exit = false;     # отключаем автосохранение (чтобы не перезаписывало)
      # Здесь можно прописать любые другие настройки, которые вы хотите зафиксировать.
      # Например, из вашего текущего btop.conf:
      truecolor = true;
      theme_background = true;
      graph_symbol = "braille";
      proc_sorting = "cpu direct";
      # ... и так далее.
    };
  };
}
