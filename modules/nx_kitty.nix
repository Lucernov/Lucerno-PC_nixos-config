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
    # Разрешает управление Kitty через внешние команды (kitty @)
    allow_remote_control yes
    # Не спрашивать подтверждение при закрытии окна
    confirm_os_window_close 0
    # Единый сокет для управления всеми окнами Kitty
    listen_on unix:/tmp/kitty-sock
    # Оболочка по умолчанию
    shell zsh
    # Стиль панели вкладок (powerline)
    tab_bar_style powerline
    # Стиль углов вкладок (скруглённые)
    tab_powerline_style round
    # Символ, показывающий активность во вкладке
    tab_activity_symbol *
    # Форма курсора (beam = вертикальная черта)
    cursor_shape beam
    # Форма курсора в неактивном окне (полый блок)
    cursor_shape_unfocused hollow
    # Интервал мигания курсора (0.5 секунды)
    cursor_blink_interval 0.5
    # Остановить мигание после 15 секунд бездействия
    cursor_stop_blinking_after 15.0
    # Список доступных вариантов раскладки окон (можно переключать)
    enabled_layouts splits,fat,grid,stack,tall,horizontal,vertical
    # Раскладка по умолчанию (разделение на панели, как в tmux)
    default_layout splits
    # Основной шрифт терминала
    font_family JetBrainsMono Nerd Font Mono
    # Размер шрифта в пунктах
    font_size 15
    # Автоматический выбор жирного начертания
    bold_font auto
    # Автоматический выбор курсивного начертания
    italic_font auto
    # Автоматический выбор жирного курсива
    bold_italic_font auto
    # принудительно включает лигатуры и контекстные альтернативы
    font_features JetBrainsMono Nerd Font Mono:liga=1,calt=1
    # Ширина нового окна терминала по умолчанию (в пикселях)
    initial_window_width 1024
    # Высота нового окна терминала по умолчанию
    initial_window_height 768
    # Прозрачность фона (0.95 = почти непрозрачный)
    background_opacity 0.5
    # Включает размытие фона, радиус размытия (можно менять от 0 до 50; чем больше, тем сильнее размытие)
    background_blur 2
    background_blur_opacity 0.5
    # Убрать рамку окна (закомментировано)
    # hide_window_decorations yes

    # ========== Настройка анимации Cursor Trail ==========
    # Включает след курсора длиной 200 ячеек
    cursor_trail 200
    # Скорость затухания: быстрое 0.1, медленное 0.4
    cursor_trail_decay 0.1 0.4
    # Минимальное расстояние (в ячейках) для начала анимации
    cursor_trail_start_threshold 2
    # (опционально) Цвет следа
    # cursor_trail_color #a6e3a1

    # ---------- Привязка клавиш (map) ----------
    # Ctrl+T – новая вкладка с текущей рабочей папкой (игнорируя соседнюю)
    map ctrl+t new_tab_with_cwd !neighbor
    # То же самое для русской раскладки (буква 'е')
    map ctrl+е new_tab_with_cwd !neighbor
    # Ctrl+W – закрыть текущую вкладку
    map ctrl+w close_tab
    # То же для русской раскладки (буква 'ц')
    map ctrl+ц close_tab
    # Ctrl+Right – следующая вкладка
    map ctrl+right next_tab
    # Ctrl+Left – предыдущая вкладка
    map ctrl+left previous_tab
    # Разделение окна по горизонтали (верх/низ)
    map ctrl+alt+e launch --location=hsplit
    # Русская раскладка (буква 'у')
    map ctrl+alt+у launch --location=hsplit
    # Разделение окна по вертикали (лево/право)
    map ctrl+alt+d launch --location=vsplit
    # Русская раскладка (буква 'в')
    map ctrl+alt+в launch --location=vsplit
    # Закрыть текущее окно/сплит
    map ctrl+alt+w close_window
    # Русская раскладка (буква 'ц')
    map ctrl+alt+ц close_window
  '';

  # Конфигурация для выпадающего режима (quick-access) – отдельный файл
  quickAccessConf = pkgs.writeText "quick-access-terminal.conf" ''
    listen_on unix:/tmp/kitty-sock
    # Количество строк в выпадающем окне
    lines 35
    # Отступ слева (для центрирования)
    margin_left 200
    # Отступ справа
    margin_right 200
    # Отступ сверху
    margin_top 2
    # Прозрачность фона 80%
    background_opacity 0.80
    # Включает размытие фона, радиус размытия (можно менять от 0 до 50; чем больше, тем сильнее размытие)
    background_blur 2
    # Убрать рамку окна
    hide_window_decorations yes
    # Не скрывать при запуске (показывать сразу)
    start_as_hidden no
    # Заголовок окна (используется для поиска)
    title quick-access
    # Шрифт терминала для выпадающего режима
    font_family JetBrainsMono Nerd Font Mono
    # Размер шрифта в пунктах
    font_size 15
    # принудительно включает лигатуры и контекстные альтернативы
    font_features JetBrainsMono Nerd Font Mono:liga=1,calt=1
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
