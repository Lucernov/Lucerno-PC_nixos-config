{ config, pkgs, lib, inputs, ... }:


let
  # UUID дисков для удобства обслуживания
  gamesUUID = "897f0999-d31e-45d1-b186-6822c7d17477";
  musicUUID = "3615f1b6-bb2e-4254-b795-f08e9a542523";
  dataUUID = "09024d77-6155-4db0-ae3c-5655858a83ad";          # 1.8TB общий для всех подтомов btrfs
  sysBackupUUID = "67a25908-e1e2-4e53-a04b-909418c0eff8";     # второй раздел системного диска @nixos-config, @ai, @sys-archiv


  # НАСТРОЙКА ФОНА ДЛЯ ЭКРАНА ВХОДА (SDDM)
  mySddmBackground = pkgs.runCommand "my-sddm-bg" {} ''
    cp ${./dotfiles/wallpapers/Velo_01.JPG} $out
  '';

    pkgs-unstable = import inputs.nixpkgs-unstable {
    system = "x86_64-linux";
    config.allowUnfree = true;
  };
in


{
  imports = [
    ./hardware-configuration.nix
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # ========== BOOTLOADER ==========
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.consoleMode = "max";
  boot.supportedFilesystems = [ "exfat" ];
  #system.nixos-init.enable = true;           # иногда проверять, пока проблемы с нвидиа
  # ЯДРО
  boot.kernelPackages = pkgs.linuxPackages_6_18;
  boot.kernelModules = [ "ntsync" ];      # Автозагрузка модуля NTSync
  boot.kernelParams = [
  "transparent_hugepage=madvise"
  "nvidia_drm.modeset=1"                   # Загружаем модуль ядра NVIDIA раньше для более гладкой загрузки и Wayland
  "mitigations=off"
  "threadirqs"                    # все прерывания в потоки – для лучшего управления приоритетами
  "preempt=full"                  # полное вытеснение ядра – снижает задержки
  "usbcore.autosuspend=-1"        # usb устройства не засыпают
  ];
  boot.kernel.sysctl = {
  "kernel.sched_autogroup_enabled" = 0;
  "kernel.sched_migration_cost_ns" = 250000;      # 0.25 мс
  "kernel.sched_min_granularity_ns" = 1000000;   # 1 мс
  "kernel.sched_wakeup_granularity_ns" = 2000000; # 2 мс
  #"vm.swappiness" = 10;
  "vm.vfs_cache_pressure" = 50;
  "vm.dirty_bytes" = 536870912;            # 512 MiB
  "vm.dirty_background_bytes" = 134217728; # 128 MiB
  "vm.stat_interval" = 10;
  "vm.dirty_writeback_centisecs" = 500;
  "vm.dirty_expire_centisecs" = 3000;
  };
  hardware.ksm.enable = false;
  musnix.enable = true;
  #musnix.snd_hda_intel.enable = false;  # Оставляем false, так как основная карта — USB
  musnix.kernel.realtime = false;       # Оставляем false для совместимости с драйверами NVIDIA


  # ========== ДОПОЛНИТЕЛЬНЫЕ ДИСКИ ==========
  # NVMe SSD для игр (ext4)
  fileSystems."/mnt/games" = {
    device = "/dev/disk/by-uuid/${gamesUUID}";
    fsType = "ext4";
    options = [ "rw" "noatime" "discard" "nobarrier" ];
  };

  # HDD для музыки (sdc1, btrfs с подтомом @music)
  fileSystems."/mnt/music" = {
    device = "/dev/disk/by-uuid/${musicUUID}";
    fsType = "btrfs";
    options = [ "subvol=@music" "compress=zstd" "noatime" "space_cache=v2" ];
  };

  # HDD с несколькими подтомами (sdb1)
  fileSystems."/mnt/archiv" = {
    device = "/dev/disk/by-uuid/${dataUUID}";
    fsType = "btrfs";
    options = [ "subvol=@archiv" "compress=zstd" "noatime" "space_cache=v2" ];
  };

  fileSystems."/mnt/docs" = {
    device = "/dev/disk/by-uuid/${dataUUID}";
    fsType = "btrfs";
    options = [ "subvol=@docs" "compress=zstd" "noatime" "space_cache=v2" ];
  };

  fileSystems."/mnt/images" = {
    device = "/dev/disk/by-uuid/${dataUUID}";
    fsType = "btrfs";
    options = [ "subvol=@images" "nodatacow" "noatime" "space_cache=v2" ];
  };

  fileSystems."/mnt/video" = {
    device = "/dev/disk/by-uuid/${dataUUID}";
    fsType = "btrfs";
    options = [ "subvol=@video" "nodatacow" "noatime" "space_cache=v2" ];
  };

  fileSystems."/mnt/video-temp" = {
    device = "/dev/disk/by-uuid/${dataUUID}";
    fsType = "btrfs";
    options = [ "subvol=@video-temp" "nodatacow" "noatime" "space_cache=v2" ];
  };

  # SSD раздел бэкапа с несколькими подтомами
  fileSystems."/home/lucerno/nixos-config" = {
    device = "/dev/disk/by-uuid/${sysBackupUUID}";
    fsType = "btrfs";
    options = [ "subvol=@nixos-config" "compress=zstd" "noatime" "space_cache=v2" "ssd" ];
  };

  fileSystems."/mnt/ai" = {
    device = "/dev/disk/by-uuid/${sysBackupUUID}";
    fsType = "btrfs";
    options = [ "subvol=@ai" "compress=zstd" "noatime" "space_cache=v2" "ssd" ];
  };

  fileSystems."/mnt/sys_archiv" = {
    device = "/dev/disk/by-uuid/${sysBackupUUID}";
    fsType = "btrfs";
    options = [ "subvol=@sys-archiv" "compress=zstd" "noatime" "space_cache=v2" "ssd" ];
  };

  # ========== ВИРТУАЛЬНЫЙ ДИСК Zram0 ==========
  zramSwap = {
    enable = true;
    memoryPercent = 25;       # Размер zram-устройства в процентах от общего объёма RAM (1/4 = 25%)
    algorithm = "lz4";
    priority = 100;
  };

  # ========== ССЫЛКИ НА ДИСКИ ==========
  systemd.tmpfiles.rules = [
    "L+ /home/lucerno/Видео - - - - /mnt/video"
    "L+ /home/lucerno/Документы - - - - /mnt/docs"
    "L+ /home/lucerno/Музыка - - - - /mnt/music"
    "L+ /home/lucerno/Изображения - - - - /mnt/images"
    "d /home/lucerno/nixos-config 0755 lucerno lucerno -"
    "d /mnt/ai 0755 lucerno lucerno -"
    "d /mnt/sys_archiv 0755 lucerno lucerno -"

    # мои симлинки
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
  # ========== КОНЕЦ ДОПОЛНИТЕЛЬНЫХ ДИСКОВ ==========


  # ========== BLUETOOTH ==========
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
  #services.blueman.enable = true;


  # ========== NVIDIA RTX 3070 ==========
  services.xserver.videoDrivers = [ "nvidia" ];
  #services.xserver.videoDrivers = [ "nouveau" ];
  hardware.graphics = {
    enable = true;                                    # Включаем поддержку аппаратного ускорения графики
    enable32Bit = true;
  };


  # Настройка драйвера NVIDIA для Wayland
  hardware.nvidia = {
    open = true;                      # Используем открытые модули (для RTX 3070 это работает)
    modesetting.enable = true;        # Обязательно для Wayland: включает режим "Sync & Destroy"
    nvidiaSettings = false;            # Устанавливает утилиту nvidia-settings
    powerManagement.enable = false;   # Отключаем управление питанием (на десктопе не нужно, только для ноутбуков)
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };


    # ========== NETWORK & SYSTEM ==========
  networking.hostName = "Lucerno-PC";
  networking.networkmanager.enable = true;

  # Firewall настройки с nftables
  networking.nftables.enable = true; # переход на nftables

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 ];     # Разрешаем SSH
    allowPing = true; # Разрешаем ping
    # Логирование подозрительных пакетов
    logRefusedConnections = false; # Не засорять логи
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
#  users.groups.realtime = {};
#  users.groups.games = {};

#security.pam.loginLimits = [
#  { domain = "@audio"; item = "rtprio"; type = "-"; value = "99"; }
#  { domain = "@audio"; item = "memlock"; type = "-"; value = "unlimited"; }
#];

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


  nixpkgs.config.allowUnfree = true;      # Разрешение unfree пакетов
  programs.zsh.enable = true;             # консоль оболочка для всех пользователей
  programs.amnezia-vpn.enable = true;     # AmneziaVPN

  # Wayland + KDE Plasma 6
  services.displayManager.sddm.enable = true;                     # Включает SDDM (Simple Desktop Display Manager)
  services.displayManager.sddm.wayland.enable = true;             # Разрешает SDDM работать под Wayland
  #services.displayManager.plasma-login-manager.enable = true;    # Plasma Login Manager (PLM) — это новый менеджер входа
  services.desktopManager.plasma6.enable = true;                  # Включает рабочий стол KDE Plasma 6
  services.displayManager.defaultSession = "plasma";              # Устанавливает сеанс по умолчанию — Plasma (KDE)
  services.xserver.enable = false;                                # Отключает X11-сервер полностью
  programs.dconf.enable = true;                                   # Включает систему хранения настроек dconf
  programs.partition-manager.enable = true;                       # Устанавливает KDE Partition Manager
  #services.tumbler.enable = true;                                 # Включает фоновую службу tumbler

  # ПОДМЕНА ФОНА SDDM
  # файл theme.conf.user внутри темы breeze. SDDM читает этот файл и применяет настройки, не затрагивая оригинальные файлы темы.
  # Параметр background указывает на пакет mySddmBackground.
  environment.systemPackages = [
    (pkgs.writeTextDir "share/sddm/themes/breeze/theme.conf.user" ''
      [General]
      background=${mySddmBackground}
    '')
  # --------------------------------------------------------------------------
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
      google-chrome           # браузер


    # Добавляем директорию для VST3
    (symlinkJoin {
      name = "vst3-plugins";
      paths = [];  # сюда можно будет добавить пакеты VST из nixpkgs
    })
  ]);

  # Переменные окружения для менеджера входа
  environment.sessionVariables = {
    LANG = "ru_RU.UTF-8";
    LANGUAGE = "ru_RU.UTF-8";

  # Переменные окружения для Wayland
    # Принудительно указываем Vulkan-драйвер NVIDIA
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    __GL_VRR_ALLOWED = "1";
    # Указываем бэкенд для GBM (Graphics Buffer Manager)
    GBM_BACKEND = "nvidia-drm";
    CHROME_FLAGS = "--ozone-platform-hint=auto";
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
    QT_QPA_PLATFORM = "wayland";
    GDK_BACKEND = "wayland";
    SDL_VIDEODRIVER = "wayland";
    QT_QPA_PLATFORM_PLUGIN_PATH = "${pkgs.qt6.qtwayland}/lib/qt-6/plugins/platforms";
  };

  # Звук (PipeWire)
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






  # STEAM
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    extraCompatPackages = with pkgs; [
      proton-ge-bin
    ];
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
    # Автоматически оптимизировать store (удалять дубликаты)
    settings.auto-optimise-store = true;

    # Автоматическая очистка старых поколений
    gc = {
      automatic = true;      # Автоматически запускать сборку мусора
      dates = "weekly";      # Раз в неделю
      options = "--delete-older-than 7d";  # Удалять поколения старше 7 дней
    };

    # Дополнительные настройки для оптимизации
    settings = {
      max-jobs = 4;                       # Параллельных сборок
      keep-derivations = true;
      keep-outputs = true;
    };
  };

    # ========== Бэкапы на Гитхаб ==========

    # Сервис, который выполняет синхронизацию
systemd.services.sync-nixos-config = {
  description = "Synchronize nixos-config with GitHub";
  script = ''
    ${pkgs.git}/bin/git -C /home/lucerno/nixos-config add --all
    if ! ${pkgs.git}/bin/git -C /home/lucerno/nixos-config diff --cached --quiet; then
      ${pkgs.git}/bin/git -C /home/lucerno/nixos-config commit -m "Автосинхронизация $(date '+\%Y-\%m-\%d \%H:\%M:\%S')"
      ${pkgs.git}/bin/git -C /home/lucerno/nixos-config push origin main
    fi
  '';
  serviceConfig = {
    Type = "oneshot";
    User = "lucerno";
  };
};

# Path unit, который следит за изменениями
systemd.paths.sync-nixos-config = {
  description = "Watch for changes in nixos-config";
  wantedBy = [ "paths.target" ];
  pathConfig = {
    PathModified = [
      "/home/lucerno/nixos-config/hardware-configuration.nix"
      "/home/lucerno/nixos-config/flake.lock"
      "/home/lucerno/nixos-config/flake.nix"
      "/home/lucerno/nixos-config/configuration.nix"
      "/home/lucerno/nixos-config/home.nix"
    ];
    Unit = "sync-nixos-config.service"; # имя сервиса для запуска
    MakeDirectory = false;
  };
};

  # ====================================================

  system.stateVersion = "25.11";
}
