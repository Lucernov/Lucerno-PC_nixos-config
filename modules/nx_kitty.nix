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

    # ---------- Основные настройки ----------
    allow_remote_control yes                                               # Разрешает управление Kitty через внешние команды (kitty @)
    confirm_os_window_close 0                                              # Не спрашивать подтверждение при закрытии окна
    listen_on unix:/tmp/kitty-sock                                         # Единый сокет для управления всеми окнами Kitty
    shell zsh                                                              # Оболочка по умолчанию
    tab_bar_style powerline                                                # Стиль панели вкладок (powerline)
    tab_powerline_style round                                              # Стиль углов вкладок (скруглённые)
    tab_activity_symbol *                                                  # Символ, показывающий активность во вкладке
    cursor_shape beam                                                      # Форма курсора (beam = вертикальная черта)
    cursor_shape_unfocused hollow                                          # Форма курсора в неактивном окне (полый блок)
    cursor_blink_interval 0.5                                              # Интервал мигания курсора (0.5 секунды)
    cursor_stop_blinking_after 15.0                                        # Остановить мигание после 15 секунд бездействия
    enabled_layouts splits,fat,grid,stack,tall,horizontal,vertical         # Список доступных вариантов раскладки окон (можно переключать)
    default_layout splits                                                  # Раскладка по умолчанию (разделение на панели, как в tmux)
    font_family JetBrainsMono Nerd Font Mono                               # Основной шрифт терминала
    font_size 15                                                           # Размер шрифта в пунктах
    bold_font auto                                                         # Автоматический выбор жирного начертания
    italic_font auto                                                       # Автоматический выбор курсивного начертания
    bold_italic_font auto                                                  # Автоматический выбор жирного курсива
    font_features JetBrainsMono Nerd Font Mono:liga=1,calt=1               # принудительно включает лигатуры и контекстные альтернативы
    # Позиционирование окна (для обычного режима, не quick-access)
    initial_window_width 1024                                              # Ширина нового окна терминала по умолчанию (в пикселях)
    initial_window_height 768                                              # Высота нового окна терминала по умолчанию
    background_opacity 0.95                                                # Прозрачность фона (0.95 = почти непрозрачный)
  # hide_window_decorations = "yes";                                       # Убрать рамку окна

    # ========== Настройка анимации Cursor Trail ==========
    cursor_trail 200                                                       # Включает след курсора длиной 200 ячеек
    cursor_trail_decay 0.1 0.4                                             # Скорость затухания: быстрое 0.1, медленное 0.4
    cursor_trail_start_threshold 2                                         # Минимальное расстояние (в ячейках) для начала анимации
  # cursor_trail_color #a6e3a1                                             # (опционально) Цвет следа

    # ---------- Привязка клавиш (map) ----------
    map ctrl+t new_tab_with_cwd !neighbor                                  # Ctrl+T – новая вкладка с текущей рабочей папкой (игнорируя соседнюю)
    map ctrl+е new_tab_with_cwd !neighbor                                  # То же самое для русской раскладки (буква 'е')
    map ctrl+w close_tab                                                   # Ctrl+W – закрыть текущую вкладку
    map ctrl+ц close_tab                                                   # То же для русской раскладки (буква 'ц')
    map ctrl+right next_tab                                                # Ctrl+Right – следующая вкладка
    map ctrl+left previous_tab                                             # Ctrl+Left – предыдущая вкладка
    map ctrl+alt+e launch --location=hsplit                                # Разделение окна по горизонтали (верх/низ)
    map ctrl+alt+у launch --location=hsplit                                # Разделение окна по горизонтали (верх/низ)
    map ctrl+alt+d launch --location=vsplit                                # Разделение окна по вертикали (лево/право)
    map ctrl+alt+в launch --location=vsplit                                # Разделение окна по вертикали (лево/право)
    map ctrl+alt+w close_window                                            # Закрыть текущее окно/сплит
    map ctrl+alt+ц close_window                                            # Русская раскладка (буква 'ц')
  '';

  # Конфигурация для выпадающего режима (quick-access) – отдельный файл
  quickAccessConf = pkgs.writeText "quick-access-terminal.conf" ''
    listen_on unix:/tmp/kitty-sock
    lines 35                                                               # Количество строк в выпадающем окне
    margin_left 200                                                        # Отступ слева (для центрирования)
    margin_right 200                                                       # Отступ справа
    margin_top 2                                                           # Отступ сверху
    background_opacity 0.80                                                # Прозрачность фона 80%
    hide_window_decorations yes                                            # Убрать рамку окна
    start_as_hidden no                                                     # Не скрывать при запуске (показывать сразу)
    title quick-access                                                     # Заголовок окна (используется для поиска)
    font_family JetBrainsMono Nerd Font Mono                               # Шрифт терминала для выпадающего режима
    font_size 15                                                           # Размер шрифта в пунктах
    font_features JetBrainsMono Nerd Font Mono:liga=1,calt=1               # принудительно включает лигатуры и контекстные альтернативы
  '';

in

{
  systemd.tmpfiles.rules = [
    "L+ ${myLib.home}/.config/kitty/kitty.conf - lucerno lucerno - ${kittyConf}"
    "L+ ${myLib.home}/.config/kitty/quick-access-terminal.conf - lucerno lucerno - ${quickAccessConf}"
    "L+ ${myLib.home}/.local/share/applications/net.local.toggle-kitty.desktop - lucerno lucerno - ${pkgs.writeText "net.local.toggle-kitty.desktop" ''
      [Desktop Entry]
      Exec=${myLib.home}/.local/bin/toggle-kitty
      Name=Toggle Kitty
      NoDisplay=true
      StartupNotify=false
      Type=Application
      X-KDE-GlobalAccel-CommandShortcut=true
    ''}"
    # Удаляем старый сокет Kitty, чтобы новый создавался с правильным именем
    "R /tmp/kitty-sock - - - - -"
    # Скрипт запуска Kitty через Win+Z (открыть/закрыть выпадающее окно)
    "L+ ${myLib.home}/.local/bin/toggle-kitty 0755 lucerno lucerno - ${pkgs.writeShellScript "toggle-kitty" ''
      export KITTY_LISTEN_ON=/tmp/kitty-sock
      if kitty @ get-window-id --match title:"quick-access" 2>/dev/null; then
          kitty @ close-window --match title:"quick-access"
      else
          kitten quick-access-terminal
      fi
    ''}"
  ];
}
