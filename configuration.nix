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

  # ========== Звук (PipeWire) ==========
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    jack.enable = true;
    pulse.enable = true;
    wireplumber.enable = true;

  extraConfig = {
    pipewire."99-low-latency" = {
      "context.properties" = {
        "default.clock.rate" = 48000;
        "default.clock.quantum" = 512;
        "default.clock.min-quantum" = 256;
        "default.clock.max-quantum" = 2048;
        "default.clock.allowed-rates" = [ 44100 48000 ];
      };
      "context.modules" = [
        {
          name = "libpipewire-module-rt";
          args = {
            "nice.level" = -15;
            "rt.prio" = 88;
          };
        }
      ];
    };
  };
};

  services.pulseaudio.enable = false;

systemd.user.services.plasma-plasmashell = {
  overrideStrategy = "asDropin";
  serviceConfig = {
    LimitNOFILE = 16384;
    Environment = "PATH=/run/current-system/sw/bin:/etc/profiles/per-user/lucerno/bin:/nix/var/nix/profiles/default/bin:/home/lucerno/.local/bin";
  };
};
systemd.user.services.kwin_wayland = {
  serviceConfig.LimitNOFILE = 16384;
};

  # ========== STEAM ==========
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    extraCompatPackages = [ pkgs-unstable.proton-ge-bin ];
  };

  hardware.xone.enable = true;      # Модули ядра
  programs.gamemode = {             # Системная служба производительности
  enable = true;
  settings = {
    general = {
      desiredgov = "performance";
      reaper_freq = 5;
    };
  };
};



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
