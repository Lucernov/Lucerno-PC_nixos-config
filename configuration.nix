{ config, pkgs, lib, pkgs-unstable, ... }:

{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];


  imports = [
    ./hardware-configuration.nix
    ./hardware.nix
    ./modules/configuration-kde_plasma.nix
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

  # --------------------------------------------------------------------------
  nixpkgs.config.allowUnfree = true;      # Разрешение unfree пакетов
  programs.zsh.enable = true;             # консоль оболочка для всех пользователей
  programs.amnezia-vpn.enable = true;     # AmneziaVPN


  # ========== NIX ОПТИМИЗАЦИЯ ==========
  nix = {
    settings.auto-optimise-store = true;         # Автоматически оптимизировать store (удалять дубликаты)

    # Автоматическая очистка старых поколений
    gc = {
      automatic = true;                          # Автоматически запускать сборку мусора
      dates = "weekly";                          # Раз в неделю
      options = "--delete-older-than 7d";        # Удалять поколения старше 7 дней
    };

    # Дополнительные настройки для оптимизации
    settings = {
      max-jobs = 6;                              # Параллельные сборки
      keep-derivations = true;
      keep-outputs = true;
    };
  };


  system.stateVersion = "25.11";
}
