{ symlinkJoin, makeWrapper, kitty, writeText }:

let
  kittyConf = writeText "kitty.conf" ''
    # ========== Kitty конфиг ==========
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
    hide_window_decorations yes

    # Клавиши
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
  '';
in
symlinkJoin {
  name = "kitty-wrapped";
  paths = [ kitty ];
  buildInputs = [ makeWrapper ];
  postBuild = ''
    mkdir -p $out/share/kitty
    cp ${kittyConf} $out/share/kitty/kitty.conf
    wrapProgram $out/bin/kitty \
      --add-flags "--config-file $out/share/kitty/kitty.conf"
  '';
}
