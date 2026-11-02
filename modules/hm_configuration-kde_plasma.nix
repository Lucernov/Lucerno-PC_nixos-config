{ pkgs, lib, myLib, ... }:
# ==============================================================================
# АРХИТЕКТУРА ТЕМИЗАЦИИ (Запомнить навсегда!)
# ==============================================================================
# 1. Stylix (nx_stylix.nix):
#    - Отвечает за TUI (btop, zsh, lsd), системные шрифты (fontconfig),
#      Plymouth (загрузку) и SDDM.
#    - Для Qt (targets.qt) и GTK (targets.gtk) ОТКЛЮЧЕН, чтобы не конфликтовать
#      с plasma-manager и ручными настройками.
#
# 2. Qt / KDE (этот файл, блок programs.plasma):
#    - Управляется через plasma-manager.
#    - Задает кастомный цвет (152,152,193), шрифты SF Pro, горячие клавиши,
#      эффекты KWin и раскладку.
#
# 3. GTK (этот файл, блоки gtk, home.file, dconf):
#    - Настроен ВРУЧНУЮ, так как встроенный gtk.theme в Home Manager ломается
#      при попытке распаковать пакет catppuccin-gtk.
#    - Тема применяется через dconf и прямую запись settings.ini.
# ==============================================================================
let
  # ========== Кастомная цветовая схема (152,152,193) для KDE ==========
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

  # ========== Отключаем Stylix для Qt в Home Manager ==========
  stylix.targets.qt.enable = lib.mkForce false;

  # =========================================================
  # GTK (Firefox, Telegram и др.) - РУЧНАЯ НАСТРОЙКА
  # =========================================================
  # Полностью отключаем встроенный модуль GTK, чтобы обойти баг с распаковкой архива темы
  gtk.enable = lib.mkForce false;

  # Вручную создаем файл конфигурации для GTK2
  home.file.".gtkrc-2.0".text = ''
    gtk-theme-name="Catppuccin-Mocha-Standard-Blue-Dark"
    gtk-icon-theme-name="Gradient-Dark-Icons"
    gtk-font-name="SF Pro 12"
    gtk-application-prefer-dark-theme=1
  '';
  # Вручную создаем файлы settings.ini для GTK3 и GTK4
  home.file.".config/gtk-3.0/settings.ini".text = ''
    [Settings]
    gtk-theme-name=Catppuccin-Mocha-Standard-Blue-Dark
    gtk-font-name=SF Pro 12
    gtk-icon-theme-name=Gradient-Dark-Icons
    gtk-application-prefer-dark-theme=1
  '';
  home.file.".config/gtk-4.0/settings.ini".text = ''
    [Settings]
    gtk-theme-name=Catppuccin-Mocha-Standard-Blue-Dark
    gtk-font-name=SF Pro 12
    gtk-icon-theme-name=Gradient-Dark-Icons
    gtk-application-prefer-dark-theme=1
  '';

  # Создаем симлинк на папку темы, чтобы GTK-приложения могли её найти
  home.file.".local/share/themes/Catppuccin-Mocha-Standard-Blue-Dark".source =
    "${pkgs.catppuccin-gtk.override { variant = "mocha"; accents = [ "blue" ]; size = "standard"; }}/share/themes/Catppuccin-Mocha-Standard-Blue-Dark";

  # Принудительно задаем значения в dconf (для fastfetch и GTK-приложений)
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      font-name = lib.mkForce "SF Pro 12";
      gtk-theme = lib.mkForce "Catppuccin-Mocha-Standard-Blue-Dark";
      icon-theme = lib.mkForce "Gradient-Dark-Icons";
    };
  };

  # Файл цветовой схемы для KDE
  home.file.".local/share/color-schemes/CatppuccinMocha.colors".source = catppuccinMochaColors;

  # =========================================================
  # QT (KDE PLASMA) - РАБОТАЕТ ЧЕРЕЗ PLASMA-MANAGER
  # =========================================================
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
        "grp:ctrl_shift_toggle"
        "grp_led:scroll"
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

    # ========== ГОРЯЧИЕ КЛАВИШИ ==========
    shortcuts = {
      "KDE Keyboard Layout Switcher" = {
        "Switch to Last-Used Keyboard Layout" = "Meta+Alt+L";
        "Switch to Next Keyboard Layout" = "Meta+Alt+K";
      };
      "services/net.local.toggle-kitty.desktop" = {
        _launch = "Meta+Z";
      };
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
      "ksmserver" = {
        "Lock Session" = "Meta+L";
        "Log Out" = "Ctrl+Alt+Del";
      };
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
