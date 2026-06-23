{ inputs, myLib, ... }:

{
  imports = [ inputs.plasma-manager.homeModules.plasma-manager ];                                       # Подключаем модуль plasma-manager, который позволяет настраивать KDE Plasma через home-manager

  programs.plasma = {                                                                                   # Блок настроек KDE Plasma
    enable = true;                                                                                      # Включаем управление Plasma через home-manager

    workspace = {                                                                                       # Настройки рабочего стола (workspace)
      wallpaper = myLib.wallpaperPath;                                                                  # Путь к файлу обоев (берётся из библиотеки lib.nix)
    };

    configFile."kxkbrc".Layout = {                                                                      # Файл конфигурации клавиатуры kxkbrc (раскладки, переключение)
      LayoutList = "us,ru";                                                                             # Список доступных раскладок: английская (us) и русская (ru)
      LayoutLoopCount = "-1";                                                                           # Бесконечный цикл переключения (при зацикливании)
      ResetOldOptions = "true";                                                                         # Сбросить старые опции раскладки
      Options = "grp:ctrl_shift_toggle,grp_led:scroll";                                                 # Переключение: Ctrl+Shift, индикатор на Scroll Lock
      ShowLayoutIndicator = "true";                                                                     # Показывать индикатор текущей раскладки в системном трее
      SwitchMode = "Global";                                                                            # Глобальное переключение раскладки (для всей системы)
      Use = "true";                                                                                     # Использовать эти настройки (активировать)
      VariantList = "";                                                                                 # Нет вариантов раскладок (пусто)
    };

    # === Kate ===
    configFile."katerc".General.Font = "JetBrains Mono,13,-1,5,400,0,0,0,0,0";                          # определение шрифта
    configFile."katerc"."KTextEditor Renderer"."Show Indentation Lines" = "true";                       # вертикальные полосы для разных блоков
    # === LSP для Nix (nil) ===
    configFile."katerc"."lspclient"."AllowedServerCommandLines" = "/run/current-system/sw/bin/nil";     # Разрешаем Kate запускать LSP-сервер nil (ука¬зываем полный путь, чтобы избежать проблем с PATH)
    configFile."lspclient/settings.json".text = builtins.toJSON {                                       # Настраиваем соответствие языка Nix и сервера nil в Kate
      servers = {
        nix = {
          command = [ "nil" ];                                                                          # Команда для запуска сервера
          highlightingModeRegex = "^Nix$";                                                              # Регулярное выражение для определения Nix-файлов по режиму подсветки
        };
      };
    };
  };
}
