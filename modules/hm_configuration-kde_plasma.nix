{ pkgs, ... }:

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

  # НИКАКИХ home.packages!!!

  # Размещаем файл цветовой схемы в правильной папке
  home.file.".local/share/color-schemes/CatppuccinMocha.colors".source = catppuccinMochaColors;

  programs.plasma = {
    enable = true;

    workspace = {
      colorScheme = "CatppuccinMocha";
    };

    fonts = {
      general = {
        family = "SF Pro";
        pointSize = 12;
      };
      fixedWidth = {
        family = "JetBrainsMono Nerd Font Mono";
        pointSize = 15;
      };
    };

    # ========== НАСТРОЙКА КЛАВИАТУРЫ ==========
    input.keyboard = {
      layouts = [
        { layout = "us"; }
        { layout = "ru"; }
      ];
      options = [
        "grp:alt_shift_toggle" # Переключение по Alt+Shift (стандарт)
      ];
    };
  };
}
