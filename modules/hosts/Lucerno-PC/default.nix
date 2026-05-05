# modules/hosts/Lucerno-PC/default.nix
{ config, pkgs, lib, pkgs-unstable, inputs, ... }:

{
  imports = [
    ../../../hardware-configuration.nix
    ../../../hardware.nix
    ../../../modules/configuration-kde_plasma.nix   # ваш модуль KDE (если есть)
    ../../../configuration.nix


    # новые профили
    # новые профили
    ../../../modules/nixos/profiles/firewall.nix
    ../../../modules/nixos/profiles/locale.nix
    ../../../modules/nixos/profiles/users.nix
    ../../../modules/nixos/profiles/sddm.nix
    ../../../modules/nixos/profiles/environment.nix
    ../../../modules/nixos/profiles/pipewire.nix
    ../../../modules/nixos/profiles/systemd-limits.nix
    ../../../modules/nixos/profiles/steam.nix
    ../../../modules/nixos/profiles/nix-optimization.nix
  ];

}
