{ config, pkgs, lib, pkgs-unstable, ... }:
let
  # НАСТРОЙКА ФОНА ДЛЯ ЭКРАНА ВХОДА (SDDM)
  mySddmBackground = pkgs.runCommand "my-sddm-bg" {} ''
    cp ${./dotfiles/wallpapers/Velo_01.JPG} $out
  '';
in


{
  imports = [
    ./hardware-configuration.nix
    ./hardware.nix
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

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


  # ========== Firewall настройки с nftables ==========
  networking.nftables.enable = true;                 # переход на nftables
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 ];                        # Разрешаем SSH
    allowPing = true;                                # Разрешаем ping
    # Логирование подозрительных пакетов
    logRefusedConnections = false;                   # Не засорять логи
    logRefusedPackets = false;
  };

    # ========== Время и локаль ==========
  time.timeZone = "Europe/Moscow";
  i18n.defaultLocale = "ru_RU.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "ru_RU.UTF-8";
    LC_IDENTIFICATION = "ru_RU.UTF-8";
    LC_MEASUREMENT = "ru_RU.UTF-8";
    LC_MONETARY = "ru_RU.UTF-8";
    LC_NAME = "ru_RU.UTF-8";
    LC_NUMERIC = "ru_RU.UTF-8";
    LC_PAPER = "ru_RU.UTF-8";
    LC_TELEPHONE = "ru_RU.UTF-8";
    LC_TIME = "ru_RU.UTF-8";
  };


  # ========== USER ==========
  # Группа для пользователя
  users.groups.lucerno = {};
  users.users.lucerno = {
    isNormalUser = true;
    hashedPasswordFile = "/home/lucerno/nixos-config/secrets/lucerno-password.hash";
    group = "lucerno";
    extraGroups = [ "wheel" "networkmanager" "audio" "video" "storage"   ];
    shell = pkgs.zsh;
  };
  # Отключаем запрос пароля для sudo для группы wheel
  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };


  # ========== Wayland + KDE Plasma 6 ==========
  services.displayManager.sddm.enable = true;                     # Включает SDDM (Simple Desktop Display Manager)
  services.displayManager.sddm.wayland.enable = true;             # Разрешает SDDM работать под Wayland
  #services.displayManager.plasma-login-manager.enable = true;    # Plasma Login Manager (PLM) — это новый менеджер входа
  services.desktopManager.plasma6.enable = true;                  # Включает рабочий стол KDE Plasma 6
  services.displayManager.defaultSession = "plasma";              # Устанавливает сеанс по умолчанию — Plasma (KDE)
  services.xserver.enable = false;                                # Отключает X11-сервер полностью
  programs.dconf.enable = true;                                   # Включает систему хранения настроек dconf
  programs.partition-manager.enable = true;                       # Устанавливает KDE Partition Manager

  # --------------------------------------------------------------------------
  nixpkgs.config.allowUnfree = true;      # Разрешение unfree пакетов
  programs.zsh.enable = true;             # консоль оболочка для всех пользователей
  programs.amnezia-vpn.enable = true;     # AmneziaVPN

  # ПОДМЕНА ФОНА SDDM
  # файл theme.conf.user внутри темы breeze. SDDM читает этот файл и применяет настройки, не затрагивая оригинальные файлы темы.
  # Параметр background указывает на пакет mySddmBackground.
  environment.systemPackages = [
    (pkgs.writeTextDir "share/sddm/themes/breeze/theme.conf.user" ''
      [General]
      background=${mySddmBackground}
    '')
  ] ++ (with pkgs; [
    home-manager
    git
    unzip
    kdePackages.plasma-desktop
    kdePackages.breeze-gtk
    vim                       # консоль системный текстовый редактор
    nano                      # консоль системный текстовый редактор
    curl
    wget
    htop
    #carbonyl                 # консольный Браузер
    nvtopPackages.nvidia      # консоль телеметрия видеокарты
    wayland-utils             # системные утилиты Wayland
    gsettings-desktop-schemas # системные схемы
    glib                      # системная библиотека
    nvidia-vaapi-driver       # драйвера видеокарты
    libva-utils               # системные утилиты VA-API

    google-chrome             # браузер
  ]);

  # ========== Переменные окружения для менеджера входа ==========
    environment.sessionVariables = {
    LANG = "ru_RU.UTF-8";
    LANGUAGE = "ru_RU.UTF-8";
  # ========== Переменные окружения для Wayland ==========
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";               # Принудительно указываем Vulkan-драйвер NVIDIA
    __GL_VRR_ALLOWED = "1";
    GBM_BACKEND = "nvidia-drm";                         # Указываем бэкенд для GBM (Graphics Buffer Manager)
    CHROME_FLAGS = "--ozone-platform-hint=auto";
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
    QT_QPA_PLATFORM = "wayland";
    GDK_BACKEND = "wayland";
    SDL_VIDEODRIVER = "wayland";
    QT_QPA_PLATFORM_PLUGIN_PATH = "${pkgs.qt6.qtwayland}/lib/qt-6/plugins/platforms";
  };

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
