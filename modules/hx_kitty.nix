
{ pkgs, ... }:

{
  # ========== Kitty терминал ==========
  programs.kitty = {
    enable = true;

    # Основные настройки (те, что обычно в kitty.conf)
    settings = {
      shell = "zsh";
      background_opacity = 0.95;
      #hide_window_decorations = "yes";
      confirm_os_window_close = 0;
        tab_bar_style = "powerline";
        tab_powerline_style = "slanted";
        tab_activity_symbol = "*";
      foreground = "#eceff4";
      background = "#2e3440";
        allow_remote_control = "yes";
        listen_on = "unix:/tmp/kitty-sock";   # единый сокет для всех окон

      # Позиционирование окна (для обычного режима, не quick-access)
      # initial_window_width = 800;
      # initial_window_height = 600;
    };

    # Привязка клавиш (map)
    keybindings = {
      "ctrl+t" = "new_tab_with_cwd !neighbor";
      "ctrl+е" = "new_tab_with_cwd !neighbor";
      "ctrl+w" = "close_tab";
      "ctrl+ц" = "close_tab";
      "ctrl+right" = "next_tab";
      "ctrl+left" = "previous_tab";

#kitty @ --to $KITTY_LISTEN_ON launch --type=tab --cwd=current
#kitty @ --to $KITTY_LISTEN_ON close-tab
    };

    # Любые другие строки, которые не поддерживаются settings/kecdybindings
    extraConfig = ''
      # Например, можно оставить комментарии
    '';
  };

  # Конфигурация для выпадающего режима (quick-access) – остаётся отдельным файлом
  xdg.configFile."kitty/quick-access-terminal.conf".text = ''
  lines 50
  margin_left 200
  margin_right 200
  margin_top 5
    background_opacity 0.80
    hide_window_decorations yes
    start_as_hidden no
    #confirm_os_window_close 0
    title quick-access
  '';

  # Скрипт для переключения Kitty
home.file.".local/bin/toggle-kitty" = {
  executable = true;
  # Ищем окно Kitty, которое запущено с идентификатором "quick-access"
  # Можно использовать class или title. Удобнее по классу, который мы сами зададим.
  text = ''
    #!${pkgs.bash}/bin/bash
    if ${pkgs.kitty}/bin/kitty @ ls 2>/dev/null | grep -q "quick-access"; then
    # Если окно существует, закрываем его
        ${pkgs.kitty}/bin/kitty @ close-window --match title:"quick-access"
    else
    # Иначе запускаем новое окно в выпадающем режиме
        ${pkgs.kitty}/bin/kitten quick-access-terminal
    fi
  '';
};

  # Systemd-сервис для автозапуска Kitty в режиме quick-access
  systemd.user.services.kitty-quick = {
    Unit.Description = "Kitty Quick Access";
    Service.ExecStart = "${pkgs.kitty}/bin/kitten quick-access-terminal";
    Install.WantedBy = [ "graphical-session.target" ];
  };

}
