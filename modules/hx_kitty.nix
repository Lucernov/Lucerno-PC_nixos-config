
{ pkgs, ... }:

{
  # ========== Kitty терминал ==========
  programs.kitty = {
    enable = true;

    # Основные настройки (те, что обычно в kitty.conf)
    settings = {
      # Оформление
      background_opacity = 1.00;
      #hide_window_decorations = "yes";
      confirm_os_window_close = 0;

      foreground = "#eceff4";
      background = "#000000";
      #background = "#2e3440";
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
  allow_remote_control yes
  listen_on unix:/tmp/kitty-sock
    size = 70% 50%
    position = center, center
    background_opacity = 0.20
    hide_window_decorations = yes
    confirm_os_window_close = 0
    foreground #ff0000
    background #ff0000
    #foreground #eceff4
    #background #2e3440
    title quick-access
  '';

  # Скрипт для переключения Kittyz
home.file.".local/bin/toggle-kitty" = {
  executable = true;
  # Ищем окно Kitty, которое запущено с идентификатором "quick-access"
  # Можно использовать class или title. Удобнее по классу, который мы сами зададим.
  text = ''
    #!${pkgs.bash}/bin/bash
    if ${pkgs.kitty}/bin/kitty @ ls 2>/dev/null | grep -q "quick-access"; then
        ${pkgs.kitty}/bin/kitty @ close-window --match title:"quick-access"
    else
        ${pkgs.kitty}/bin/kitty --config /home/lucerno/.config/kitty/quick-access-terminal.conf
    fi
  '';
};

  # Systemd-сервис для автозапуска Kitty в режиме quick-access
systemd.user.services.kitty-quick = {
  Unit.Description = "Kitty Quick Access";
  Service.ExecStart = "${pkgs.kitty}/bin/kitty --config /home/lucerno/.config/kitty/quick-access-terminal.conf";
  Install.WantedBy = [ "graphical-session.target" ];
};
}
