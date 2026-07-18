{ config, pkgs, myLib, ... }:

{
  systemd.tmpfiles.rules = [
    "L+ ${myLib.home}/.config/kitty/kitty.conf - lucerno lucerno - ${pkgs.writeText "kitty.conf" ''
      # Цвета Catppuccin Mocha (фиксированные)
      foreground #cdd6f4
      background #1e1e2e
      selection_background #cdd6f4
      selection_foreground #1e1e2e
      color0 #45475a
      color1 #f38ba8
      color2 #a6e3a1
      color3 #f9e2af
      color4 #89b4fa
      color5 #cba6f7
      color6 #94e2d5
      color7 #bac2de
      color8 #585b70
      color9 #f38ba8
      color10 #a6e3a1
      color11 #f9e2af
      color12 #89b4fa
      color13 #cba6f7
      color14 #94e2d5
      color15 #a6adc8

      # Ваши настройки
      font_family JetBrainsMono Nerd Font Mono
      font_size 15
      allow_remote_control yes
      confirm_os_window_close 0
      listen_on unix:/tmp/kitty-sock
      shell zsh
      tab_bar_style powerline
      tab_powerline_style round
      tab_activity_symbol *
      cursor_shape beam
      cursor_shape_unfocused hollow
      cursor_blink_interval 0.5
      cursor_stop_blinking_after 15.0
      enabled_layouts splits,fat,grid,stack,tall,horizontal,vertical
      default_layout splits
      background_opacity 0.95
      hide_window_decorations no

      # Хоткеи
      map ctrl+t new_tab_with_cwd !neighbor
      map ctrl+е new_tab_with_cwd !neighbor
      map ctrl+w close_tab
      map ctrl+ц close_tab
      map ctrl+right next_tab
      map ctrl+left previous_tab
      map ctrl+alt+e launch --location=hsplit
      map ctrl+alt+у launch --location=hsplit
      map ctrl+alt+d launch --location=vsplit
      map ctrl+alt+в launch --location=vsplit
      map ctrl+alt+w close_window
      map ctrl+alt+ц close_window

      # Cursor trail
      cursor_trail 200
      cursor_trail_decay 0.1 0.4
      cursor_trail_start_threshold 2
    ''}"
  ];
}
