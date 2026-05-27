{ pkgs, ... }:
{
  # ========== Kitty терминал ==========
  programs.kitty = {
    enable = true;                                                                # Включает генерацию конфигурации Kitty
    package = null;                                                               # Не устанавливаем Kitty через home-manager (пакет уже установлен системно)

    # Основные настройки (те, что обычно в kitty.conf)
    settings = {
      allow_remote_control = "yes";                                               # Разрешает управление Kitty через внешние команды (kitty @)
      background = "#2e3440";                                                     # Цвет фона (тёмно-серый, как в Nord)
      background_opacity = 0.95;                                                  # Прозрачность фона (0.95 = почти непрозрачный)
      confirm_os_window_close = 0;                                                # Не спрашивать подтверждение при закрытии окна
      foreground = "#eceff4";                                                     # Цвет текста (светло-серый)
      listen_on = "unix:/tmp/kitty-sock";                                         # Единый сокет для управления всеми окнами Kitty
      shell = "zsh";                                                              # Оболочка по умолчанию
      tab_bar_style = "powerline";                                                # Стиль панели вкладок (powerline)
      tab_powerline_style = "round";                                              # Стиль углов вкладок (скруглённые)
      tab_activity_symbol = "*";                                                  # Символ, показывающий активность во вкладке
      cursor_shape = "beam";                                                      # Форма курсора (beam = вертикальная черта)
      cursor_shape_unfocused = "hollow";                                          # Форма курсора в неактивном окне (полый блок)
      cursor_blink_interval = 0.5;                                                # Интервал мигания курсора (0.5 секунды)
      cursor_stop_blinking_after = 15.0;                                          # Остановить мигание после 15 секунд бездействия
      #hide_window_decorations = "yes";                                           # Убрать рамку окна
      # Позиционирование окна (для обычного режима, не quick-access)
      initial_window_width = 1024;
      initial_window_height = 768;
      enabled_layouts = "splits,fat,grid,stack,tall,horizontal,vertical";
      default_layout = "splits";
    };

    # Привязка клавиш (map)
    keybindings = {
      "ctrl+t" = "new_tab_with_cwd !neighbor";                                    # Ctrl+T – новая вкладка с текущей рабочей папкой (игнорируя соседнюю)
      "ctrl+е" = "new_tab_with_cwd !neighbor";                                    # То же самое для русской раскладки (буква 'е')
      "ctrl+w" = "close_tab";                                                     # Ctrl+W – закрыть текущую вкладку
      "ctrl+ц" = "close_tab";                                                     # То же для русской раскладки (буква 'ц')
      "ctrl+right" = "next_tab";                                                  # Ctrl+Right – следующая вкладка
      "ctrl+left" = "previous_tab";                                               # Ctrl+Left – предыдущая вкладка
      "ctrl+alt+e" = "launch --location=hsplit";                                  # Разделение окна по горизонтали (верх/низ)
      "ctrl+alt+у" = "launch --location=hsplit";                                  # Разделение окна по горизонтали (верх/низ)
      "ctrl+alt+d" = "launch --location=vsplit";                                  # Разделение окна по вертикали (лево/право)
      "ctrl+alt+в" = "launch --location=vsplit";                                  # Разделение окна по вертикали (лево/право)
      "ctrl+alt+w" = "close_window";                                              # Закрыть текущее окно/сплит
      "ctrl+alt+ц" = "close_window";                                              # Русская раскладка (буква 'ц')
    };

    # Любые другие строки, которые не поддерживаются settings/keybindings
    extraConfig = ''
      # ========== Настройка анимации Cursor Trail (появилось в Kitty 0.37.0) ==========
      # Включает след курсора длиной 200 ячеек
      cursor_trail 200
      # Скорость затухания: быстрое 0.1, медленное 0.4
      cursor_trail_decay 0.1 0.4
      # Минимальное расстояние (в ячейках) для начала анимации
      cursor_trail_start_threshold 2
      # (опционально) Цвет следа (закомментировано)
      # cursor_trail_color #a6e3a1
    '';
  };

  # Конфигурация для выпадающего режима (quick-access) – отдельный файл
  xdg.configFile."kitty/quick-access-terminal.conf".text = ''
    # Количество строк в выпадающем окне
    lines 50
    # Отступ слева (для центрирования)
    margin_left 200
    # Отступ справа
    margin_right 200
    # Отступ сверху
    margin_top 2
    # Прозрачность фона 80%
    background_opacity 0.80
    # Убрать рамку окна
    hide_window_decorations yes
    # Не скрывать при запуске (показывать сразу)
    start_as_hidden no
    # Заголовок окна (используется для поиска)
    title quick-access
  '';

  # Скрипт для переключения Kitty (открыть/закрыть выпадающее окно)
  home.file.".local/bin/toggle-kitty" = {
    executable = true;                                                             # Делаем файл исполняемым
    text = ''
      #!${pkgs.bash}/bin/bash
      if ${pkgs.kitty}/bin/kitty @ ls 2>/dev/null | grep -q "quick-access"; then
          ${pkgs.kitty}/bin/kitty @ close-window --match title:"quick-access"
      else
          ${pkgs.kitty}/bin/kitten quick-access-terminal
      fi
    '';
  };
}
