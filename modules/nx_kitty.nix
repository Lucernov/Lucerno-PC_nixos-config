{ pkgs, myLib, ... }:

let
  kittyConf = pkgs.writeText "kitty.conf" ''
    # Цвета Catppuccin Mocha (фиксированные, чтобы не зависеть от Stylix)
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

    # Основные настройки
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
    font_family JetBrainsMono Nerd Font Mono
    font_size 15
    bold_font auto
    italic_font auto
    bold_italic_font auto
    font_features JetBrainsMono Nerd Font Mono:liga=1,calt=1
    initial_window_width 1024
    initial_window_height 768
    background_opacity 0.95

    # extraConfig (cursor trail)
    cursor_trail 200
    cursor_trail_decay 0.1 0.4
    cursor_trail_start_threshold 2

    # keybindings
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
  '';

  quickAccessConf = pkgs.writeText "quick-access-terminal.conf" ''
    listen_on unix:/tmp/kitty-sock
    lines 35
    margin_left 200
    margin_right 200
    margin_top 2
    background_opacity 0.80
    hide_window_decorations yes
    start_as_hidden no
    title quick-access
    font_family JetBrainsMono Nerd Font Mono
    font_size 15
    font_features JetBrainsMono Nerd Font Mono:liga=1,calt=1
  '';

in
{
  systemd.tmpfiles.rules = [
    "L+ ${myLib.home}/.config/kitty/kitty.conf - lucerno lucerno - ${kittyConf}"
    "L+ ${myLib.home}/.config/kitty/quick-access-terminal.conf - lucerno lucerno - ${quickAccessConf}"
  ];
}
