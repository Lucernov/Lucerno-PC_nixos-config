{ pkgs, myLib, ... }:

let
  # ========== Кастомная цветовая схема KDE (Catppuccin Mocha + кастомный акцент) ==========
  catppuccinMochaColors = pkgs.writeText "CatppuccinMocha.colors" ''
    [ColorEffects:Disabled]
    Color=49,50,68
    ColorAmount=0
    ColorEffect=0
    ContrastAmount=0.45
    ContrastEffect=1
    IntensityAmount=0.1
    IntensityEffect=2

    [ColorEffects:Inactive]
    ChangeSelectionColor=true
    Color=108,112,134
    ColorAmount=0.025
    ColorEffect=2
    ContrastAmount=0.1
    ContrastEffect=2
    Enable=true
    IntensityAmount=0
    IntensityEffect=0

    [Colors:Button]
    BackgroundAlternate=69,71,90
    BackgroundNormal=69,71,90
    DecorationFocus=152,152,193
    DecorationHover=152,152,193
    ForegroundActive=116,199,236
    ForegroundInactive=186,194,222
    ForegroundLink=137,180,250
    ForegroundNegative=243,139,168
    ForegroundNeutral=249,226,175
    ForegroundNormal=205,214,244
    ForegroundPositive=166,227,161
    ForegroundVisited=137,180,250

    [Colors:Complementary]
    BackgroundAlternate=24,24,37
    BackgroundNormal=30,30,46
    DecorationFocus=152,152,193
    DecorationHover=152,152,193
    ForegroundActive=152,152,193
    ForegroundInactive=186,194,222
    ForegroundLink=152,152,193
    ForegroundNegative=243,139,168
    ForegroundNeutral=249,226,175
    ForegroundNormal=205,214,244
    ForegroundPositive=166,227,161
    ForegroundVisited=147,153,178

    [Colors:Selection]
    BackgroundAlternate=69,71,90
    BackgroundNormal=152,152,193
    DecorationFocus=152,152,193
    DecorationHover=152,152,193
    ForegroundActive=116,199,236
    ForegroundInactive=186,194,222
    ForegroundLink=137,180,250
    ForegroundNegative=243,139,168
    ForegroundNeutral=249,226,175
    ForegroundNormal=255,255,255
    ForegroundPositive=166,227,161
    ForegroundVisited=137,180,250

    [Colors:Tooltip]
    BackgroundAlternate=69,71,90
    BackgroundNormal=16,16,25
    DecorationFocus=152,152,193
    DecorationHover=152,152,193
    ForegroundActive=116,199,236
    ForegroundInactive=186,194,222
    ForegroundLink=137,180,250
    ForegroundNegative=243,139,168
    ForegroundNeutral=249,226,175
    ForegroundNormal=205,214,244
    ForegroundPositive=166,227,161
    ForegroundVisited=137,180,250

    [Colors:View]
    BackgroundAlternate=37,37,54
    BackgroundNormal=34,34,51
    DecorationFocus=152,152,193
    DecorationHover=152,152,193
    ForegroundActive=116,199,236
    ForegroundInactive=186,194,222
    ForegroundLink=137,180,250
    ForegroundNegative=243,139,168
    ForegroundNeutral=249,226,175
    ForegroundNormal=205,214,244
    ForegroundPositive=166,227,161
    ForegroundVisited=137,180,250

    [Colors:Window]
    BackgroundAlternate=24,24,37
    BackgroundNormal=30,30,46
    DecorationFocus=152,152,193
    DecorationHover=152,152,193
    ForegroundActive=116,199,236
    ForegroundInactive=186,194,222
    ForegroundLink=137,180,250
    ForegroundNegative=243,139,168
    ForegroundNeutral=249,226,175
    ForegroundNormal=205,214,244
    ForegroundPositive=166,227,161
    ForegroundVisited=137,180,250

    [General]
    Name=CatppuccinMocha
    shadeSortColumn=true

    [KDE]
    contrast=7

    [WM]
    activeBackground=30,30,46
    activeBlend=30,30,46
    activeForeground=205,214,244
    inactiveBackground=30,30,46
    inactiveBlend=30,30,46
    inactiveForeground=186,194,222
  '';
in
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

      # Принудительно задаем GTK-тему, чтобы KDE не перебивала её
      GTK_THEME = "Catppuccin-Mocha-Standard-Blue-Dark";
    };

    # ========== Настройка фона SDDM ==========
    systemPackages = with pkgs; [
      (writeTextDir "share/sddm/themes/breeze/theme.conf.user" ''
        [General]
        background=${myLib.wallpaperPath}
      '')
    ];
  };

  # ========== Настройка GTK через dconf (запасной вариант) ==========
  # KDE может перезаписывать dconf, но мы оставляем это для приложений,
  # которые читают настройки напрямую оттуда.
  programs.dconf.profiles.user.databases = [{
    settings = {
      "org/gnome/desktop/interface" = {
        gtk-theme = "Catppuccin-Mocha-Standard-Blue-Dark";
        color-scheme = "prefer-dark";
      };
    };
  }];

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

  # ========== Настройки KDE, GTK и корзины ==========
  systemd.tmpfiles.rules = [
    # ---------- Кастомная цветовая схема KDE ----------
    (myLib.mkDir "${myLib.home}/.local/share/color-schemes")
    (myLib.mkLink "${myLib.home}/.local/share/color-schemes/CatppuccinMocha.colors" catppuccinMochaColors)

    # ---------- Принудительное применение GTK-темы ----------
    # KDE-служба kde-gtk-config при старте перезаписывает эти файлы на Breeze.
    # Делаем их read-only симлинками на Nix Store, чтобы KDE не могла их изменить.
    (myLib.mkDir "${myLib.home}/.config/gtk-3.0")
    (myLib.mkLink "${myLib.home}/.config/gtk-3.0/settings.ini" (pkgs.writeText "gtk3-settings.ini" ''
      [Settings]
      gtk-theme-name = Catppuccin-Mocha-Standard-Blue-Dark
      gtk-application-prefer-dark-theme = 1
    ''))

    (myLib.mkDir "${myLib.home}/.config/gtk-4.0")
    (myLib.mkLink "${myLib.home}/.config/gtk-4.0/settings.ini" (pkgs.writeText "gtk4-settings.ini" ''
      [Settings]
      gtk-theme-name = Catppuccin-Mocha-Standard-Blue-Dark
      gtk-application-prefer-dark-theme = 1
    ''))

    # ---------- Настройки корзины ----------
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
