{ pkgs, myLib, ... }:

{
  # ========== Настройки дисплейного менеджера и рабочего стола ==========
  services = {
    displayManager = {                                              # Настройка дисплейного менеджера SDDM
      plasma-login-manager.enable = true;                           # Включает Plasma Login Manager (экран входа в KDE Plasma)
      defaultSession = "plasma";                                    # Указывает, какая сессия рабочего стола будет запускаться по умолчанию. Значение "plasma" соответствует KDE Plasma (может быть "plasma" или "plasmawayland")
    };
    desktopManager.plasma6.enable = true;                           # Подключает все необходимые системные службы, компоненты и настройки, чтобы KDE Plasma 6 могла работать в качестве основной графической среды
    xserver.enable = false;                                         # Запрещает запуск X11-сервера. Вся графика будет работать через Wayland (рекомендуется для Plasma 6 и NVIDIA с драйвером 545+)
  };

  # ========== Переменные окружения для сессии SDDM ==========
  environment.sessionVariables = {                                  # Локаль для интерфейса SDDM и приложений (русский язык)
    LANG = "ru_RU.UTF-8";                                           # Основной язык системы
    LANGUAGE = "ru_RU.UTF-8";                                       # Дополнительный язык
    QT_QPA_PLATFORMTHEME = "kde";                                   # Тема Qt для приложений (использовать тему KDE)
  };

  # ========== Настройка фона SDDM ==========
  environment.systemPackages = with pkgs; [
    (writeTextDir "share/sddm/themes/breeze/theme.conf.user" ''
      [General]
      # Путь к изображению обоев для экрана входа (берётся из myLib)
      background=${myLib.wallpaperPath}
    '')
  ];

  # Установка обоев при старте сессии (от пользователя)
  systemd.user.services.set-wallpaper = {
    description = "Set Plasma wallpaper";
    after = [ "graphical-session.target" ];
    wantedBy = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.kdePackages.plasma-workspace}/bin/plasma-apply-wallpaperimage ${myLib.wallpaperPath}";
    };
  };
}
