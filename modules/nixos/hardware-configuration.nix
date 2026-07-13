{ config, pkgs, lib, modulesPath, myLib, inputs, ... }:

let
  # UUID дисков
  bootUUID = "59A7-C7F6";                                     # EFI раздел
  sysUUID = "1964f286-7b1d-40df-8201-5824671e9631";           # корень системы + библиотека NIX + home
  sysBackupUUID = "67a25908-e1e2-4e53-a04b-909418c0eff8";     # второй раздел системного диска @nixos-config (${myLib.configDirName}), @ai, @sys-archiv

  gamesUUID = "897f0999-d31e-45d1-b186-6822c7d17477";         # игры
  musicUUID = "3615f1b6-bb2e-4254-b795-f08e9a542523";         # музыка
  dataUUID = "09024d77-6155-4db0-ae3c-5655858a83ad";          # 1.8TB общий для всех подтомов btrfs
in

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  # ========== ОСНОВНОЙ ДИСК ==========
  fileSystems = {
    "/boot" = {
      device = "/dev/disk/by-uuid/${bootUUID}";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };

    "/" = {
      device = "/dev/disk/by-uuid/${sysUUID}";
      fsType = "btrfs";
      options = [ "subvol=@" "compress=zstd" "noatime" "space_cache=v2" "ssd" ];
    };

    "/nix" = {
      device = "/dev/disk/by-uuid/${sysUUID}";
      fsType = "btrfs";
      options = [ "subvol=@nix" "compress=zstd" "noatime" "space_cache=v2" "ssd" ];
    };

    "/home" = {
      device = "/dev/disk/by-uuid/${sysUUID}";
      fsType = "btrfs";
      options = [ "subvol=@home" "compress=zstd" "noatime" "space_cache=v2" "ssd" ];
      neededForBoot = true;
    };


    # ========== ДОПОЛНИТЕЛЬНЫЕ ДИСКИ ==========
    # SSD раздел бэкапа с несколькими подтомами
    "/home/lucerno/${myLib.configDirName}" = {
      device = "/dev/disk/by-uuid/${sysBackupUUID}";
      fsType = "btrfs";
      options = [ "subvol=@${myLib.configDirName}" "compress=zstd" "noatime" "space_cache=v2" "ssd" ];
    };

    "/mnt/sys_archiv" = {
      device = "/dev/disk/by-uuid/${sysBackupUUID}";
      fsType = "btrfs";
      options = [ "subvol=@sys-archiv" "compress=zstd" "noatime" "space_cache=v2" "ssd" ];
    };

    "/mnt/ai" = {
      device = "/dev/disk/by-uuid/${sysBackupUUID}";
      fsType = "btrfs";
      options = [ "subvol=@ai" "compress=zstd" "noatime" "space_cache=v2" "ssd" ];
    };

    # NVMe SSD для игр (ext4)
    "/mnt/games" = {
      device = "/dev/disk/by-uuid/${gamesUUID}";
      fsType = "ext4";
      options = [ "rw" "noatime" "discard" "nobarrier" ];
    };

    # HDD для музыки (sdc1, btrfs с подтомом @music)
    "/mnt/music" = {
      device = "/dev/disk/by-uuid/${musicUUID}";
      fsType = "btrfs";
      options = [ "subvol=@music" "compress=zstd" "noatime" "space_cache=v2" ];
    };

  # HDD с несколькими подтомами (sdb1)
    "/mnt/archiv" = {
      device = "/dev/disk/by-uuid/${dataUUID}";
      fsType = "btrfs";
      options = [ "subvol=@archiv" "compress=zstd" "noatime" "space_cache=v2" ];
    };

    "/mnt/docs" = {
      device = "/dev/disk/by-uuid/${dataUUID}";
      fsType = "btrfs";
      options = [ "subvol=@docs" "compress=zstd" "noatime" "space_cache=v2" ];
    };

    "/mnt/images" = {
      device = "/dev/disk/by-uuid/${dataUUID}";
      fsType = "btrfs";
      options = [ "subvol=@images" "nodatacow" "noatime" "space_cache=v2" ];
    };

    "/mnt/video" = {
      device = "/dev/disk/by-uuid/${dataUUID}";
      fsType = "btrfs";
      options = [ "subvol=@video" "nodatacow" "noatime" "space_cache=v2" ];
    };

    "/mnt/video-temp" = {
      device = "/dev/disk/by-uuid/${dataUUID}";
      fsType = "btrfs";
      options = [ "subvol=@video-temp" "nodatacow" "noatime" "space_cache=v2" ];
    };
  };

  swapDevices = [ ];                                                        # Традиционный swap-раздел/файл не используется (отключён)

  # ========== ВИРТУАЛЬНЫЙ ДИСК Zram0 ==========
  zramSwap = {
    enable = true;                                                          # Включить сжатие оперативной памяти в ZRAM (используется как подкачка)
    memoryPercent = 25;                                                     # Размер zram-устройства в процентах от общего объёма RAM (1/4 = 25%)
    algorithm = "lz4";                                                      # Алгоритм сжатия (lz4 – быстрый, хорошая степень сжатия)
    priority = 100;                                                         # Приоритет использования zram-устройства (чем выше, тем предпочтительнее)
  };

  # ========== КОНЕЦ РАЗДЕЛА ДИСКОВ ==========

  # ========== ЖЕЛЕЗО ==========
  hardware = {
    cpu.intel.updateMicrocode = true;                                       # Включает загрузку актуального микрокода для процессоров Intel
    enableRedistributableFirmware = true;                                   # Разрешает использование проприетарных прошивок
    bluetooth = {
      enable = true;                                                        # Включить поддержку Bluetooth
      powerOnBoot = true;                                                   # Включить Bluetooth-адаптер при загрузке
    };
    graphics = {
      enable = true;                                                        # Включаем поддержку аппаратного ускорения графики
      enable32Bit = true;                                                   # Поддержка 32‑битных приложений
      extraPackages = with pkgs; [ nvidia-vaapi-driver ];                   # VA‑API драйвер для NVIDIA
    };
    nvidia = {
      open = true;                                                          # Используем открытые модули
      modesetting.enable = true;                                            # Обязательно для Wayland
      nvidiaSettings = true;                                                # Устанавливает утилиту nvidia-settings
      powerManagement.enable = false;                                       # Отключаем управление питанием (на десктопе не нужно)
      package = config.boot.kernelPackages.nvidiaPackages.stable;           # Версия драйвера
    };
    ksm.enable = false;                                                     # Kernel Same‑page Merging – отключено (нужно только для виртуализации)
  };

  # ========== ЗАГРУЗКА И ЯДРО ==========
  boot = {
    kernelPackages = inputs.nix-cachyos-kernel.legacyPackages.${pkgs.system}."linuxPackages-cachyos-bore-lto-x86_64-v3";  # Установка кастомного CachyOS ядра для intel i5 13400f процессора
  # kernelPackages = pkgs.linuxPackages_zen;                                # Установка кастомного ZEN ядра
  # kernelPackages = pkgs.linuxPackages;                                    # Базовое ядро

    initrd.kernelModules = [                                                # Модули, загружаемые на раннем этапе (initrd)
      "nvidia"                                                              # Основной драйвер NVIDIA
      "nvidia_modeset"                                                      # Управление режимами видеовыхода (необходимо для Wayland)
      "nvidia_drm"                                                          # Интеграция NVIDIA с DRM (Direct Rendering Manager)
    ];

    kernelModules = [                                                       # Модули на основном этапе
      "ntsync"                                                              # Модуль для улучшения синхронизации в Wine/Proton (игры)
      "nvidia_uvm"                                                          # Unified Virtual Memory для NVIDIA (CUDA, OpenCL, AI)
      "intel_rapl_msr"                                                      # Модуль для чтения энергопотребления процессора (RAPL). Нужен для btop, powertop и других утилит.
    # "kvm-intel"                                                           # Модуль аппаратной виртуализации KVM для процессоров Intel
    ];

    initrd.availableKernelModules = [                                       # Модули, которые могут быть загружены динамически при обнаружении оборудования
      "vmd"                                                                 # Intel Volume Management Device (для NVMe и RAID)
      "xhci_pci"                                                            # USB 3.0/3.1 контроллеры
      "ahci"                                                                # SATA контроллеры (AHCI)
      "nvme"                                                                # NVMe SSD
      "usbhid"                                                              # USB HID-устройства (клавиатуры, мыши)
      "usb_storage"                                                         # USB Mass Storage (флешки, внешние диски)
      "sd_mod"                                                              # SCSI диск (SD-карты, некоторые HDD/SSD)
    ];

    extraModulePackages = [ ];                                              # Дополнительные пакеты модулей ядра (пусто – не используются)

    kernelParams = [                                                        # Параметры, передаваемые ядру при загрузке (через командную строку)
      "nvidia_drm.modeset=1"                                                # Включить режимный сет DRM NVIDIA (нужен для Wayland)
      "nvidia_drm.fbdev=1"                                                  # включает фреймбуфер через DRM (для консоли и раннего вывода)
      "video=DP-1:2560x1440@60,video=HDMI-A-1:1920x1080@60"                 # принудительно устанавливает разрешение консоли
      "fbcon=map:1"                                                         # Привязывает фреймбуфер консоли к первому видеовыходу (обычно основному монитору)
      "fbcon=font:TER16x32"                                                 # Устанавливает шрифт консоли: TER16x32 (высокое разрешение, 16x32 пикселя)
      "vt.global_cursor_default=0"                                          # Отключает мигающий курсор в виртуальных консолях (tty)
      "transparent_hugepage=madvise"                                        # Использовать прозрачные огромные страницы только по запросу madvise
      #"threadirqs"                                                          # Превратить все прерывания в потоки (улучшает отзывчивость при аудио)
      #"preempt=full"                                                        # Полная вытесняемость ядра (снижает задержки, полезно для реального времени)
      "rcupdate.rcu_cpu_stall_timeout=60"                                   # Таймаут ожидания RCU (60 сек) – диагностика зависаний
      "usbcore.autosuspend=-1"                                              # Отключить автоматическую приостановку USB-устройств
      "clocksource=tsc"                                                     # Использовать TSC (Time Stamp Counter) как источник времени
      "tsc=reliable"                                                        # Считать TSC надёжным (не сбрасывается при состояниях сна)
      "irqaffinity=0"                                                       # Перенаправить все аппаратные прерывания на процессор 0
      "nowatchdog"                                                          # Отключить сторожевые таймеры (watchdog)
      "quiet"                                                               # Подавляет большую часть сообщений ядра в консоли (оставляет только важные предупреждения и ошибки)
      "rd.systemd.show_status=auto"                                         # Управляет выводом статуса systemd в initrd: показывает только ошибки и важные события. Значение auto — systemd сам решает, когда показывать статус
      "rd.udev.log_priority=3"                                              # Устанавливает уровень логирования для udev в initrd (3 = ошибки). Уменьшает шум от udev.
      "usbcore.quirks=07fd:0008:k,q"                                        # Явно указывает ядру применять quirk для MOTU M4
    ];

    kernel.sysctl = {                                                       # Тонкая настройка ядра (sysctl)
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
      "kernel.printk" = "3 3 3 3";                                          # Устанавливает уровни логирования для консоли, системного лога, сообщений по умолчанию и ограничений. Только сообщения уровня KERN_ERR и выше (ошибки)
      "net.core.default_qdisc" = "fq";                                      # Устанавливает глобальный планировщик очередей для сетевых интерфейсов: fq (Fair Queue)
      "net.ipv4.tcp_congestion_control" = "bbr";                            # Использует алгоритм управления перегрузкой TCP BBR (Bottleneck Bandwidth and RTT). Даёт значительный прирост скорости передачи данных
    };

    # ========== НАСТРОЙКИ INITRD (начальный загрузочный образ) ==========
    initrd = {
      systemd.enable = true;                                                # Использовать systemd в initrd вместо скриптов. Ускоряет загрузку, позволяет параллельно запускать службы
      verbose = false;                                                      # Отключает подробный вывод сообщений initrd (делает загрузку более чистой и быстрой).
    };

    consoleLogLevel = 3;                                                    # Устанавливает минимальный уровень важности сообщений ядра, выводимых на консоль. Будут показаны только ошибки и критические сообщения (уровень KERN_ERR и выше).
    tmp.cleanOnBoot = true;                                                 # Автоматически очищает каталог /tmp при каждой загрузке системы. Повышает безопасность (удаляет временные файлы, созданные другими пользователями)
  };

    # ========== СЕТЬ ==========
  networking = {
    hostName = "Lucerno-PC";                                                # Имя компьютера в сети
    networkmanager.enable = true;                                           # Включает NetworkManager (управление сетями, Wi‑Fi, VPN)
  };

  # ========== Services (общий блок) ==========
  services = {
    udev.extraRules = ''
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

    fwupd.enable = true;                                                    # Включает демон fwupd для автоматического обновления прошивок устройств (UEFI, USB, диски и др.)
    xserver.videoDrivers = [ "nvidia" ];                                    # Использовать проприетарный драйвер NVIDIA (NVIDIA RTX 3070)
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";                      # Определяет архитектуру системы (x86_64). mkDefault позволяет переопределить извне, если потребуется
}
