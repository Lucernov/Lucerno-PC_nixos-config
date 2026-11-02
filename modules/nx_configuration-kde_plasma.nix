{ pkgs, myLib, ... }:

{
  # ========== Настройки дисплейного менеджера и рабочего стола ==========
  services = {
    displayManager = {                                              # Настройка дисплейного менеджера SDDM
      plasma-login-manager.enable = true;                           # Включить Plasma Login Manager (экран входа в KDE Plasma)
      defaultSession = "plasma";                                    # Указать, какая сессия рабочего стола будет запускаться по умолчанию.
      autoLogin = {                                                 # Автологин в сессию
        enable = true;
        user = myLib.userName;
      };
    };
    desktopManager.plasma6.enable = true;                           # Подключить все необходимые системные службы KDE Plasma 6
    xserver.enable = false;                                         # Запретить запуск X11-сервера. Вся графика будет работать через Wayland
  };

  environment = {
    # ========== Переменные окружения для сессии ==========
    sessionVariables = {
      LANG = "ru_RU.UTF-8";                                         # Основной язык системы
      LANGUAGE = "ru_RU.UTF-8";                                     # Дополнительный язык
      QT_QPA_PLATFORMTHEME = "kde";                                 # Тема Qt для приложений
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
  # Если plasma-manager научится задавать обои, этот сервис можно будет убрать.
  systemd.user.services.set-wallpaper = {
    description = "Set Plasma wallpaper";
    after = [ "graphical-session.target" ];
    wantedBy = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.kdePackages.plasma-workspace}/bin/plasma-apply-wallpaperimage ${myLib.wallpaperPath}";
    };
  };

  # ========== Настройки корзины ==========
  # plasma-manager может не поддерживать все опции ktrashrc, поэтому оставляем их здесь.
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

      [/mnt/www-GoogleDrive/.Trash-1000]
      Days=7
      LimitReachedAction=0
      Percent=10
      UseSizeLimit=false
      UseTimeLimit=false
      trash_disable=true

      [/mnt/www-OneDrive/.Trash-1000]
      Days=7
      LimitReachedAction=0
      Percent=10
      UseSizeLimit=false
      UseTimeLimit=false
      trash_disable=true

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
