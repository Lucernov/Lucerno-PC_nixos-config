
{ pkgs, ... }:

{
  # ========== Kitty терминал ==========
  programs.kitty = {
    enable = true;                     # Включает генерацию конфигурации
    package = null;                    # отключает установку пакета

    # Основные настройки (те, что обычно в kitty.conf)
    settings = {
      allow_remote_control = "yes";
      background = "#2e3440";
      background_opacity = 0.95;
      confirm_os_window_close = 0;
      foreground = "#eceff4";
      listen_on = "unix:/tmp/kitty-sock";   # единый сокет для всех окон
      shell = "zsh";
      tab_bar_style = "powerline";
      tab_powerline_style = "round";
      tab_activity_symbol = "*";
      cursor_shape = "beam";                # Форма курсора (block, beam, underline)
      cursor_shape_unfocused = "hollow";
      cursor_blink_interval = 0.5;          # Интервал мигания (секунды)
      cursor_stop_blinking_after = 15.0;    # Через сколько секунд бездействия остановить мига
      #hide_window_decorations = "yes";
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
    };

    # Любые другие строки, которые не поддерживаются settings/kecdybindings
    extraConfig = ''
      # ========== Настройка анимации Cursor Trail (появилось в Kitty 0.37.0) ==========
      # Включаем анимацию
      cursor_trail 200

      # Скорость затухания следа (быстрое — 0.1, медленное — 0.4)
      cursor_trail_decay 0.1 0.4

      # Минимальное расстояние для запуска анимации (в ячейках)
      cursor_trail_start_threshold 2

      # Цвет следа (необязательно, можно не указывать)
      # cursor_trail_color #a6e3a1

      #kitty @ --to $KITTY_LISTEN_ON launch --type=tab --cwd=current
      #kitty @ --to $KITTY_LISTEN_ON close-tab
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
