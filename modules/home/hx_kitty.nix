{ pkgs, ... }:
{
  programs.kitty = {
    enable = true;
    extraConfig = ''
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

      cursor_trail 200
      cursor_trail_decay 0.1 0.4
      cursor_trail_start_threshold 2
    '';
  };
}
