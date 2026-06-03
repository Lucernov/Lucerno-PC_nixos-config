{ config, pkgs, lib, modulesPath, myLib, ... }:

let
  # UUID дисков
  bootUUID = "59A7-C7F6";
  sysUUID = "1964f286-7b1d-40df-8201-5824671e9631";
  sysBackupUUID = "67a25908-e1e2-4e53-a04b-909418c0eff8";     # второй раздел системного диска @nixos-config (${myLib.configDirName}), @ai, @sys-archiv

  gamesUUID = "897f0999-d31e-45d1-b186-6822c7d17477";
  musicUUID = "3615f1b6-bb2e-4254-b795-f08e9a542523";
  dataUUID = "09024d77-6155-4db0-ae3c-5655858a83ad";          # 1.8TB общий для всех подтомов btrfs
in

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  services.udev.extraRules = ''
    # Все SSD и NVMe (kyber – планировщик, оптимизированный для NVMe/SSD с низкой задержкой и высокой пропускной способностью)
    ACTION=="add|change", KERNEL!="zram*", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="kyber"
    # Все HDD (mq-deadline – планировщик, разработанный для HDD, обеспечивает минимальную задержку операций)
    ACTION=="add|change", ATTR{queue/rotational}=="1", ATTR{queue/scheduler}="mq-deadline"
    # NVMe диск для игр (специфические настройки read-ahead)
    ACTION=="add|change", KERNEL=="nvme0n1", ATTR{bdi/read_ahead_kb}="512"
    # HDD — увеличенный read-ahead для повышения производительности при чтении больших файлов
    ACTION=="add|change", ATTR{queue/rotational}=="1", ATTR{bdi/read_ahead_kb}="1024"

    # --- Устройства реального времени для аудио ---
    KERNEL=="rtc0", GROUP="audio"
    KERNEL=="hpet", GROUP="audio"
  '';

  # ========== ОСНОВНОЙ ДИСК ==========
  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/${bootUUID}";
    fsType = "vfat";
    options = [ "fmask=0077" "dmask=0077" ];
  };

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/${sysUUID}";
    fsType = "btrfs";
    options = [ "subvol=@" "compress=zstd" "noatime" "space_cache=v2" "ssd" ];
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/${sysUUID}";
    fsType = "btrfs";
    options = [ "subvol=@nix" "compress=zstd" "noatime" "space_cache=v2" "ssd" ];
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/${sysUUID}";
    fsType = "btrfs";
    options = [ "subvol=@home" "compress=zstd" "noatime" "space_cache=v2" "ssd" ];
    neededForBoot = true;
  };


  # ========== ДОПОЛНИТЕЛЬНЫЕ ДИСКИ ==========
  # SSD раздел бэкапа с несколькими подтомами
  fileSystems."/home/lucerno/${myLib.configDirName}" = {
    device = "/dev/disk/by-uuid/${sysBackupUUID}";
    fsType = "btrfs";
    options = [ "subvol=@${myLib.configDirName}" "compress=zstd" "noatime" "space_cache=v2" "ssd" ];
  };

  fileSystems."/mnt/sys_archiv" = {
    device = "/dev/disk/by-uuid/${sysBackupUUID}";
    fsType = "btrfs";
    options = [ "subvol=@sys-archiv" "compress=zstd" "noatime" "space_cache=v2" "ssd" ];
  };

  fileSystems."/mnt/ai" = {
    device = "/dev/disk/by-uuid/${sysBackupUUID}";
    fsType = "btrfs";
    options = [ "subvol=@ai" "compress=zstd" "noatime" "space_cache=v2" "ssd" ];
  };

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


  swapDevices = [ ];                                                        # Традиционный swap-раздел/файл не используется (отключён)

  # ========== ВИРТУАЛЬНЫЙ ДИСК Zram0 ==========
  zramSwap = {
    enable = true;                                                          # Включить сжатие оперативной памяти в ZRAM (используется как подкачка)
    memoryPercent = 25;                                                     # Размер zram-устройства в процентах от общего объёма RAM (1/4 = 25%)
    algorithm = "lz4";                                                      # Алгоритм сжатия (lz4 – быстрый, хорошая степень сжатия)
    priority = 100;                                                         # Приоритет использования zram-устройства (чем выше, тем предпочтительнее)
  };


  # ========== ССЫЛКИ НА ДИСКИ ==========
  systemd.tmpfiles.rules = [
    "L+ /home/lucerno/Видео - - - - /mnt/video"
    "L+ /home/lucerno/Документы - - - - /mnt/docs"
    "L+ /home/lucerno/Музыка - - - - /mnt/music"
    "L+ /home/lucerno/Изображения - - - - /mnt/images"
    "d /home/lucerno/${myLib.configDirName} 0755 lucerno lucerno -"
    "d /mnt/ai 0755 lucerno lucerno -"
    "d /mnt/sys_archiv 0755 lucerno lucerno -"
    "z /sys/class/powercap/intel-rapl:*/energy_uj 0640 root powercap -"
  ];
  # ========== КОНЕЦ РАЗДЕЛА ДИСКОВ ==========


  # ========== Обновление микрокода процессора i5 13400f и прошивок ==========
  hardware.cpu.intel.updateMicrocode = true;                              # Включает загрузку актуального микрокода для процессоров Intel (исправление уязвимостей, стабильность)
  hardware.enableRedistributableFirmware = true;                          # Разрешает использование проприетарных прошивок для некоторых устройств (Wi-Fi, Bluetooth, GPU и т.д.)
  services.fwupd.enable = true;                                           # Включает демон fwupd для автоматического обновления прошивок устройств (UEFI, USB, диски и др.)


  # ========== ЯДРО И ЕГО МОДУЛИ ==========
  #boot.kernelPackages = pkgs.linuxPackages;                              # Выбор стабильной версии стандартного ядра
  boot.kernelPackages = pkgs.linuxPackages_zen;                           # Установка кастомного ZEN ядра

  boot.kernelModules = [                                                  # Модули ядра, загружаемые на основном этапе (после initrd)
  #  "kvm-intel"                                                          # Модуль аппаратной виртуализации KVM для процессоров Intel
    "ntsync"                                                              # Модуль для улучшения синхронизации в Wine/Proton (игры)
    "nvidia_uvm"                                                          # Unified Virtual Memory для NVIDIA (CUDA, OpenCL, AI)
    "intel_rapl_msr"                                                      # Модуль для чтения энергопотребления процессора (RAPL). Нужен для btop, powertop и других утилит.
  ];
  boot.initrd.kernelModules = [                                           # Модули, загружаемые на раннем этапе (в initrd) – до монтирования корневой ФС
    "nvidia"                                                              # Основной драйвер NVIDIA
    "nvidia_modeset"                                                      # Управление режимами видеовыхода (необходимо для Wayland)
    "nvidia_drm"                                                          # Интеграция NVIDIA с DRM (Direct Rendering Manager)
  ];

  boot.initrd.availableKernelModules = [                                  # Модули, которые могут быть загружены динамически при обнаружении оборудования
    "vmd"                                                                 # Intel Volume Management Device (для NVMe и RAID)
    "xhci_pci"                                                            # USB 3.0/3.1 контроллеры
    "ahci"                                                                # SATA контроллеры (AHCI)
    "nvme"                                                                # NVMe SSD
    "usbhid"                                                              # USB HID-устройства (клавиатуры, мыши)
    "usb_storage"                                                         # USB Mass Storage (флешки, внешние диски)
    "sd_mod"                                                              # SCSI диск (SD-карты, некоторые HDD/SSD)
  ];

  boot.extraModulePackages = [ ];                                         # Дополнительные пакеты модулей ядра (пусто – не используются)

  boot.kernelParams = [                                                   # Параметры, передаваемые ядру при загрузке (через командную строку)
    "nvidia_drm.modeset=1"                                                # Включить режимный сет DRM NVIDIA (нужен для Wayland)
    "nvidia_drm.fbdev=1"                                                  # ОТКЛЮЧИТЬ фреймбуфер через DRM (для консоли и раннего вывода)
    "video=DP-1:2560x1440@60"                                             # принудительно устанавливает разрешение консоли
    "transparent_hugepage=madvise"                                        # Использовать прозрачные огромные страницы только по запросу madvise
    "threadirqs"                                                          # Превратить все прерывания в потоки (улучшает отзывчивость при аудио)
    "preempt=full"                                                        # Полная вытесняемость ядра (снижает задержки, полезно для реального времени)
    "rcupdate.rcu_cpu_stall_timeout=60"                                   # Таймаут ожидания RCU (60 сек) – диагностика зависаний
    "usbcore.autosuspend=-1"                                              # Отключить автоматическую приостановку USB-устройств
    "clocksource=tsc"                                                     # Использовать TSC (Time Stamp Counter) как источник времени
    "tsc=reliable"                                                        # Считать TSC надёжным (не сбрасывается при состояниях сна)
    "irqaffinity=0"                                                       # Перенаправить все аппаратные прерывания на процессор 0
    "nowatchdog"                                                          # Отключить сторожевые таймеры (watchdog)
  ];


  # ========== Тонкая настройка ядра (sysctl) ==========
  boot.kernel.sysctl = {
    "kernel.sched_autogroup_enabled" = 0;                                 # Отключить автогруппировку процессов (автоматическое объединение задач в группы)
    "kernel.sched_base_slice_ns" = 2000000;                               # Базовая длительность кванта времени для планировщика (2 мс) – влияет на отзывчивость
    "vm.swappiness" = 10;                                                 # Предпочтение подкачке: 0..100. 10 – система будет почти всегда держать данные в ОЗУ
    "vm.vfs_cache_pressure" = 50;                                         # Давление на кэш VFS (50 – уменьшает вытеснение inode/dentry из памяти, повышает производительность)
    "vm.dirty_bytes" = 536870912;                                         # Максимальное количество "грязных" данных (кэш записи) в байтах (512 MiB)
    "vm.dirty_background_bytes" = 134217728;                              # Порог для фоновой записи грязных данных (128 MiB) – когда начинается сброс на диск
    "vm.stat_interval" = 10;                                              # Интервал статистики VM (10 секунд)
    "vm.dirty_writeback_centisecs" = 500;                                 # Интервал сброса грязных данных (500 сотых секунды = 5 секунд)
    "vm.dirty_expire_centisecs" = 3000;                                   # Время жизни грязных данных (3000 сотых секунды = 30 секунд) – по истечении принудительный сброс
    "vm.max_map_count" = 1048576;                                         # Максимальное количество отображений памяти (memory maps) для процесса (полезно для игр и больших приложений)
  };
  # ========== KSM (отключён) ==========
  hardware.ksm.enable = false;                                            # Kernel Same‑page Merging – отключено (не нужно для ПК, только для виртуализации)

  # ========== NETWORK & SYSTEM ==========
  networking.hostName = "Lucerno-PC";                                     # Имя компьютера в сети
  networking.networkmanager.enable = true;                                # Включает NetworkManager (управление сетями, Wi‑Fi, VPN)
  #networking.networkmanager.wifi.backend = "iwd";                        # (закомментировано) Альтернативный бэкенд Wi‑Fi – iwd (вместо wpa_supplicant)

  # ========== Bluetooth ==========
  hardware.bluetooth = {
    enable = true;                                                        # Включить поддержку Bluetooth
    powerOnBoot = true;                                                   # Включить Bluetooth-адаптер при загрузке
  };

  # ========== NVIDIA RTX 3070 ==========
  services.xserver.videoDrivers = [ "nvidia" ];                           # Использовать проприетарный драйвер NVIDIA
  hardware.graphics = {
    enable = true;                                                        # Включаем поддержку аппаратного ускорения графики
    enable32Bit = true;                                                   # Поддержка 32‑битных приложений (игры, Wine)
    extraPackages = with pkgs; [ nvidia-vaapi-driver ];                   # VA‑API драйвер для NVIDIA (аппаратное кодирование/декодирование видео)
  };
  # Настройка драйвера NVIDIA для Wayland
  hardware.nvidia = {
    open = true;                                                          # Используем открытые модули
    modesetting.enable = true;                                            # Обязательно для Wayland: включает режим "Sync & Destroy"
    nvidiaSettings = true;                                                # Устанавливает утилиту nvidia-settings
    powerManagement.enable = false;                                       # Отключаем управление питанием (на десктопе не нужно)
    package = config.boot.kernelPackages.nvidiaPackages.stable;           # Версия драйвера
  };


  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
