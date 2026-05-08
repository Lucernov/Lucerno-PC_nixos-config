{ pkgs, ... }:

{
  # ========== Kitty терминал ==========
  programs.kitty = {
    enable = true;

    # Основные настройки (те, что обычно в kitty.conf)
    settings = {
      # Оформление
      background_opacity = 0.85;
      hide_window_decorations = "yes";
      confirm_os_window_close = 0;
      foreground = "#eceff4";
      background = "#2e3440";
      # Позиционирование окна (для обычного режима, не quick-access)
      # initial_window_width = 800;
      # initial_window_height = 600;
    };

    # Привязка клавиш (map)
    keybindings = {
      "ctrl+shift+t" = "new_tab_with_cwd !neighbor";
      "ctrl+shift+q" = "close_tab";
      "ctrl+shift+right" = "next_tab";
      "ctrl+shift+left" = "previous_tab";
      "super+w" = "close_tab";
    };

    # Любые другие строки, которые не поддерживаются settings/keybindings
    extraConfig = ''
      # Например, можно оставить комментарии
    '';
  };

  # Конфигурация для выпадающего режима (quick-access) – остаётся отдельным файлом
  xdg.configFile."kitty/quick-access-terminal.conf".text = ''
    size = 70% 50%
    position = center, center
    background_opacity = 0.85
    hide_window_decorations = yes
    confirm_os_window_close = 0
    foreground #eceff4
    background #2e3440
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
