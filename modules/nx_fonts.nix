{ pkgs, ... }:

{
  # ========== Настройки шрифтов ==========
  fonts.fontDir.enable = true;                                    # Включает общую директорию со шрифтами в /run/current-system/sw/share/X11/fonts
  fonts.packages = with pkgs; [
    noto-fonts-color-emoji                                        # Цветные эмодзи
    noto-fonts                                                    # Базовый набор для всех языков
    noto-fonts-cjk-sans                                           # CJK (китайский, японский, корейский) — без засечек
    dejavu_fonts                                                  # Классический fallback с широким покрытием Unicode
    liberation_ttf                                                # Свободная замена Arial, Times, Courier
    inter                                                         # Современный интерфейсный шрифт
    nerd-fonts.jetbrains-mono                                     # Шрифт для кода с лигатурами и доп. иконками
    lucerno-packages.apple-fonts-lite                             # Шрифты Apple SF-Pro и New-York
  ];
}
