{ config, pkgs, ... }:

{
  # ========== Включение и базовые настройки btop ==========
  programs.btop = {
    enable = true;
    settings = {

      # ----- Внешний вид и тема -----
      color_theme = "adapta";            # название темы (системная или из ~/.config/btop/themes/)
      truecolor = true;                  # 24-битный цвет
      theme_background = true;           # показывать фон темы (иначе прозрачность терминала)
      graph_symbol = "braille";          # символы для графиков (braille / block / tty)



      # ----- Часы и время работы -----
      clock_format = "%X";               # формат времени (локальный, например, 23:59:59)
      show_uptime = true;                # показывать время работы системы (uptime)

    };
  };
}
