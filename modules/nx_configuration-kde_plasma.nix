{ pkgs, myLib, ... }:

{
  # ========== Настройки дисплейного менеджера и рабочего стола ==========
  services = {
    displayManager = {                                              # Настройка дисплейного менеджера SDDM
      plasma-login-manager.enable = true;                           # Включить Plasma Login Manager (экран входа в KDE Plasma)
      defaultSession = "plasma";                                    # Указать, какая сессия рабочего стола будет запускаться по умолчанию. Значение "plasma" соответствует KDE Plasma (может быть "plasma" или "plasmawayland")
      autoLogin = {                                                 # Автологин в сессию
        enable = true;
        user = myLib.userName;
      };
    };
    desktopManager.plasma6.enable = true;                           # Подключить все необходимые системные службы, компоненты и настройки, чтобы KDE Plasma 6 могла работать в качестве основной графической среды
    xserver.enable = false;                                         # Запретить запуск X11-сервера. Вся графика будет работать через Wayland (рекомендуется для Plasma 6 и NVIDIA с драйвером 545+)
  };

  environment = {
    # ========== Переменные окружения для сессии SDDM ==========
    sessionVariables = {                                              # Локаль для интерфейса SDDM и приложений (русский язык)
      LANG = "ru_RU.UTF-8";                                           # Основной язык системы
      LANGUAGE = "ru_RU.UTF-8";                                       # Дополнительный язык
      QT_QPA_PLATFORMTHEME = "kde";                                   # Тема Qt для приложений (использовать тему KDE)
    };

    # ========== Настройка фона SDDM ==========
    systemPackages = with pkgs; [
      (writeTextDir "share/sddm/themes/breeze/theme.conf.user" ''
        [General]
        background=${myLib.wallpaperPath}
      '')
    ];
  };

  # ========== Установка обоев при старте сессии (от пользователя) ==========
  systemd.user.services.set-wallpaper = {
    description = "Set Plasma wallpaper";
    after = [ "graphical-session.target" ];
    wantedBy = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.kdePackages.plasma-workspace}/bin/plasma-apply-wallpaperimage ${myLib.wallpaperPath}";
    };
  };

   # ========== Настройки корзины KDE ==========
  systemd.tmpfiles.rules = [
    (myLib.mkLink "${myLib.home}/.config/ktrashrc" (pkgs.writeText "ktrashrc" ''
      [/home/lucerno/.local/share/Trash]
      Days=7
      LimitReachedAction=0
      Percent=10
      UseSizeLimit=true
      UseTimeLimit=false

      [/mnt/video-temp/.Trash-1000]
      Days=7
      LimitReachedAction=0
      Percent=10
      UseSizeLimit=true
      UseTimeLimit=false

      [/mnt/video/.Trash-1000]
      Days=7
      LimitReachedAction=0
      Percent=10
      UseSizeLimit=true
      UseTimeLimit=false

      # --- Изменения для rclone (добавлено trash_disable=true) ---
      # --- Секция для GoogleDrive ---
      [/mnt/www-GoogleDrive/.Trash-1000]
      Days=7
      LimitReachedAction=0
      Percent=10
      UseSizeLimit=false
      UseTimeLimit=false
      trash_disable=true

      # --- Секция для OneDrive ---
      [/mnt/www-OneDrive/.Trash-1000]
      Days=7
      LimitReachedAction=0
      Percent=10
      UseSizeLimit=false
      UseTimeLimit=false
      trash_disable=true

      # --- Секция для Яндекс.Диска ---
      [/mnt/www-YandexDisk/.Trash-1000]
      Days=7
      LimitReachedAction=0
      Percent=10
      UseSizeLimit=false
      UseTimeLimit=false
      trash_disable=true
    ''))
  ];
}
