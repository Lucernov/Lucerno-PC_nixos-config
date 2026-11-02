{ pkgs, lib, myLib, ... }:

let
  # ========== Твоя кастомная цветовая схема (152,152,193) ==========
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
  home.stateVersion = "26.05";

    # ========== Настройка GTK (Firefox, Telegram и др.) ==========
  gtk = {
    enable = true;
    font = {
      name = lib.mkForce "SF Pro";
      size = lib.mkForce 12;
    };
    theme = {
      name = lib.mkForce "Catppuccin-Mocha-Standard-Blue-Dark";
    };
    iconTheme = {
      name = lib.mkForce "Gradient-Dark-Icons";
    };
  };

  # ========== Принудительная настройка dconf ==========
  # Перебиваем дефолтные значения модуля GNOME (DejaVu Sans)
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      font-name = lib.mkForce "SF Pro 12";
      gtk-theme = lib.mkForce "Catppuccin-Mocha-Standard-Blue-Dark";
      icon-theme = lib.mkForce "Gradient-Dark-Icons";
    };
  };

  # Размещаем файл цветовой схемы в правильной папке
  home.file.".local/share/color-schemes/CatppuccinMocha.colors".source = catppuccinMochaColors;

  programs.plasma = {
    enable = true;

    workspace = {
      colorScheme = "CatppuccinMocha";
      iconTheme = "Gradient-Dark-Icons";
      wallpaper = myLib.wallpaperPath;
      windowDecorations = {
        library = "org.kde.breeze";
        theme = "Breeze";
      };
    };

    fonts = {
      general = {
        family = "SF Pro";
        pointSize = 12;
      };
      fixedWidth = {
        family = "JetBrains Mono";
        pointSize = 12;
      };
    };

    # ========== НАСТРОЙКА КЛАВИАТУРЫ ==========
    input.keyboard = {
      layouts = [
        { layout = "us"; }
        { layout = "ru"; }
      ];
      options = [
        "grp:ctrl_shift_toggle" # Переключение по Ctrl+Shift
        "grp_led:scroll"        # Индикация Scroll Lock
      ];
    };

    # ========== ЭФФЕКТЫ KWIN И ВИРТУАЛЬНЫЕ СТОЛЫ ==========
    kwin = {
      virtualDesktops = {
        number = 2;
        rows = 2;
      };
      effects = {
        blur.enable = true;
        translucency.enable = true;
      };
    };

    # ========== ГОРЯЧИЕ КЛАВИШИ (ПЕРЕНОС ИЗ СТАРОГО KXKBRC) ==========
    shortcuts = {
      # Переключение раскладки по Meta+Alt+K / L (в дополнение к Ctrl+Shift)
      "KDE Keyboard Layout Switcher" = {
        "Switch to Last-Used Keyboard Layout" = "Meta+Alt+L";
        "Switch to Next Keyboard Layout" = "Meta+Alt+K";
      };

      # Твоя Kitty на Meta+Z
      "services/net.local.toggle-kitty.desktop" = {
        _launch = "Meta+Z";
      };

      # Управление окнами (KWin)
      "kwin" = {
        "Expose" = "Meta+F9";
        "ExposeAll" = "Meta+F10";
        "ExposeClass" = "Meta+F7";
        "Grid View" = "Meta+G";
        "Kill Window" = "Meta+Ctrl+Esc";
        "Show Desktop" = "Meta+D";
        "Switch One Desktop Down" = "Meta+Ctrl+Down";
        "Switch One Desktop Up" = "Meta+Ctrl+Up";
        "Switch One Desktop to the Left" = "Meta+Ctrl+Left";
        "Switch One Desktop to the Right" = "Meta+Ctrl+Right";
        "Switch Window Down" = "Meta+Alt+Down";
        "Switch Window Left" = "Meta+Alt+Left";
        "Switch Window Right" = "Meta+Alt+Right";
        "Switch Window Up" = "Meta+Alt+Up";
        "Switch to Desktop 1" = "Meta+F1";
        "Switch to Desktop 2" = "Meta+F2";
        "Switch to Desktop 3" = "Meta+F3";
        "Switch to Desktop 4" = "Meta+F4";
        "Window Close" = "Alt+F4";
        "Window Maximize" = "Meta+PgUp";
        "Window Minimize" = "Meta+PgDown";
        "Window Quick Tile Bottom" = "Meta+Down";
        "Window Quick Tile Left" = "Meta+Left";
        "Window Quick Tile Right" = "Meta+Right";
        "Window Quick Tile Top" = "Meta+Up";
        "Walk Through Windows" = "Meta+Tab";
        "Walk Through Windows (Reverse)" = "Meta+Shift+Tab";
        "Walk Through Windows of Current Application" = "Meta+`";
        "Walk Through Windows of Current Application (Reverse)" = "Meta+~";
        "Window to Next Screen" = "Meta+Shift+Right";
        "Window to Previous Screen" = "Meta+Shift+Left";
      };

      # Блокировка и выход
      "ksmserver" = {
        "Lock Session" = "Meta+L";
        "Log Out" = "Ctrl+Alt+Del";
      };

      # Панель задач и меню пуск
      "plasmashell" = {
        "activate application launcher" = "Meta";
        "activate task manager entry 1" = "Meta+1";
        "activate task manager entry 2" = "Meta+2";
        "activate task manager entry 3" = "Meta+3";
        "activate task manager entry 4" = "Meta+4";
        "activate task manager entry 5" = "Meta+5";
        "activate task manager entry 6" = "Meta+6";
        "activate task manager entry 7" = "Meta+7";
        "activate task manager entry 8" = "Meta+8";
        "activate task manager entry 9" = "Meta+9";
        "manage activities" = "Meta+Q";
        "show dashboard" = "Ctrl+F12";
        "show-on-mouse-pos" = "Meta+V";
      };
    };
  };
}
