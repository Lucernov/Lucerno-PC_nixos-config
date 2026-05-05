# modules/hosts/Lucerno-PC/default.nix
{ config, pkgs, lib, pkgs-unstable, inputs, ... }:

{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  imports = [
    ../../../hardware-configuration.nix
    ../../../hardware.nix
    ../../../modules/configuration-kde_plasma.nix

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
    #../../../modules/nixos/profiles/programs.nix
  ];

  # ========== мои симлинки ==========
  systemd.tmpfiles.rules = [
    "L+ /home/lucerno/drum_sklad - - - - /mnt/sys_archiv/samples/drum_sklad"
    "d /home/lucerno/.local/share 0755 lucerno lucerno -"
    "L+ /home/lucerno/.local/share/Steam/userdata - - - - /home/lucerno/nixos-config/dotfiles/config/Steam/userdata"
    "L+ /home/lucerno/.local/share/vital - - - - /mnt/sys_archiv/samples/vital"
    "d /home/lucerno/.config 0755 lucerno lucerno -"
    "L+ /home/lucerno/.config/AmneziaVPN.ORG - - - - /home/lucerno/nixos-config/dotfiles/config/AmneziaVPN.ORG"
    "L+ /home/lucerno/.config/obs-studio - - - - /home/lucerno/nixos-config/dotfiles/config/obs-studio"
    "L+ /home/lucerno/.config/DecentSampler - - - - /mnt/sys_archiv/samples/DecentSampler"
    "L+ /home/lucerno/.config/REAPER - - - - /home/lucerno/nixos-config/dotfiles/config/REAPER"
    "L+ /home/lucerno/.config/yabridgectl - - - - /home/lucerno/nixos-config/dotfiles/config/yabridgectl"
  ];

  system.stateVersion = "25.11";
}
