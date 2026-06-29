{ config, pkgs, inputs, ... }:

{
  fonts.packages = with pkgs; [
    noto-fonts-color-emoji                                                  # Цветные эмодзи
    noto-fonts                                                              # Базовый набор для всех языков
    liberation_ttf                                                          # Свободная замена Arial, Times, Courier
    inter                                                                   # Современный интерфейсный шрифт
    nerd-fonts.jetbrains-mono                                               # Шрифт для кода с лигатурами и доп. иконками
    inputs.apple-fonts.packages.${pkgs.stdenv.hostPlatform.system}.sf-pro   # Apple SF-Pro
    inputs.apple-fonts.packages.${pkgs.stdenv.hostPlatform.system}.ny       # Apple New-York
  ];
}
