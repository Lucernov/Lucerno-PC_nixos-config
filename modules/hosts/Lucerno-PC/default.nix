# modules/hosts/Lucerno-PC/default.nix
{ config, pkgs, lib, pkgs-unstable, inputs, ... }:

{
  imports = [
    ../../../hardware-configuration.nix
    ../../../hardware.nix
    ../../../modules/configuration-kde_plasma.nix   # ваш модуль KDE (если есть)
    ../../../configuration.nix


    # новые профили
    ../../../modules/nixos/profiles/firewall.nix
  ];

  # все остальные системные настройки (firewall, время, пользователь, звук, steam и т.д.)
  # пока копируем сюда из configuration.nix, но потом разобьём на профили

  # Временно скопируем сюда всё содержимое configuration.nix (кроме imports).
  # Для начала просто импортируем старый configuration.nix, но это временно.
  # Лучше по частям переносить.
}
