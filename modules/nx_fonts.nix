{ pkgs, ... }:

{
  fonts.packages = with pkgs; [
    noto-fonts-color-emoji                                                  # Цветные эмодзи
    noto-fonts                                                              # Базовый набор для всех языков
    liberation_ttf                                                          # Свободная замена Arial, Times, Courier
    inter                                                                   # Современный интерфейсный шрифт
    nerd-fonts.jetbrains-mono                                               # Шрифт для кода с лигатурами и доп. иконками
    lucerno-packages.apple-fonts-lite                                            # Шрифты Apple SF-Pro и New-York
  ];
}
