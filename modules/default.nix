# modules/default.nix
{ config, pkgs, lib, pkgs-unstable, inputs, ... }:

{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  imports = [
    ../hardware-configuration.nix
    ../hardware.nix

    # новые профили
    ./nx_locale.nix
    ./nx_users.nix
    ./nx_sddm.nix
    ./nx_firewall.nix
    ./nx_environment.nix
    ./nx_pipewire.nix
    ./nx_systemd-limits.nix
    ./nx_steam.nix
    ./nx_optimization.nix
    ./nx_configuration-kde_plasma.nix
    ./nx_soft-sys.nix
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
