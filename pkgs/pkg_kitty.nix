{ symlinkJoin, makeWrapper, kitty }:
symlinkJoin {
  name = "kitty-wrapped";
  paths = [ kitty ];
  buildInputs = [ makeWrapper ];
  postBuild = ''
    mkdir -p $out/share/kitty
    cat > $out/share/kitty/kitty.conf <<EOF
      # ваш конфиг
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
      # ... остальные настройки
    EOF
    wrapProgram $out/bin/kitty \
      --set KITTY_CONFIG_DIRECTORY $out/share/kitty
  '';
}
