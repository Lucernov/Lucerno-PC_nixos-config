{ config, pkgs, lib, pkgs-unstable, ... }:

let
  # UUID дисков
  gamesUUID = "897f0999-d31e-45d1-b186-6822c7d17477";
  musicUUID = "3615f1b6-bb2e-4254-b795-f08e9a542523";
  dataUUID = "09024d77-6155-4db0-ae3c-5655858a83ad";          # 1.8TB общий для всех подтомов btrfs
  sysBackupUUID = "67a25908-e1e2-4e53-a04b-909418c0eff8";     # второй раздел системного диска @nixos-config, @ai, @sys-archiv
in

{
services.udev.extraRules = ''
  # Все SSD и NVMe
  ACTION=="add|change", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="kyber"
  # Все HDD
  ACTION=="add|change", ATTR{queue/rotational}=="1", ATTR{queue/scheduler}="mq-deadline"
  # NVMe диск для игр
  ACTION=="add|change", KERNEL=="nvme0n1", ATTR{bdi/read_ahead_kb}="512"
  # HDD — read-ahead 1024 KB
  ACTION=="add|change", ATTR{queue/rotational}=="1", ATTR{bdi/read_ahead_kb}="1024"
'';


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
#Однако, поскольку ZRAM уже включен и отлично работает, у вас нет необходимости его менять. Он обеспечивает потрясающую скорость и защищает ваш SSD от износа. Но если в будущем вы обнаружите, что игровой процесс стал не таким плавным при заполненной памяти, имеет смысл рассмотреть переход на ZSWAP для более эффективного распределения ресурсов.

  # ========== ССЫЛКИ НА ДИСКИ ==========
  systemd.tmpfiles.rules = [
    "L+ /home/lucerno/Видео - - - - /mnt/video"
    "L+ /home/lucerno/Документы - - - - /mnt/docs"
    "L+ /home/lucerno/Музыка - - - - /mnt/music"
    "L+ /home/lucerno/Изображения - - - - /mnt/images"
    "d /home/lucerno/nixos-config 0755 lucerno lucerno -"
    "d /mnt/ai 0755 lucerno lucerno -"
    "d /mnt/sys_archiv 0755 lucerno lucerno -"
  ];
  # ========== КОНЕЦ ДОПОЛНИТЕЛЬНЫХ ДИСКОВ ==========


  # ========== Загрузчик ==========
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
    systemd-boot.consoleMode = "max";
  };
  boot.supportedFilesystems = [ "exfat" ];
  #system.nixos-init.enable = true;                        # иногда проверять, пока проблемы с нвидиа

  # ========== Ядро и его модули ==========
  boot.kernelPackages = pkgs.linuxPackages_6_18;
  boot.kernelModules = [ "ntsync" ];                       # Автозагрузка модуля NTSync
  boot.kernelParams = [
    "transparent_hugepage=madvise"
    "nvidia_drm.modeset=1"                                 # Загружаем модуль ядра NVIDIA раньше для более гладкой загрузки и Wayland
    "mitigations=off"
    "threadirqs"                                           # все прерывания в потоки – для лучшего управления приоритетами
    "preempt=full"                                         # полное вытеснение ядра – снижает задержки
    "rcupdate.rcu_cpu_stall_timeout=60"
    "usbcore.autosuspend=-1"                               # usb устройства не засыпают
    "nohz_full=2-15"
    "isolcpus=2-15"
  # "rcu_nocbs=2-15"                                       # этот параметр автоматически подразумевается nohz_full и его можно не указывать
    "clocksource=tsc tsc=reliable"
    "irqaffinity=0"                                        # перенаправить все IRQ на ядро 0
    "nowatchdog"
    "mce=ignore_ce"
  ];

  # ========== Тонкая настройка ядра (sysctl) ==========
  boot.kernel.sysctl = {
    "kernel.sched_autogroup_enabled" = 0;
    "kernel.sched_migration_cost_ns" = 250000;      # 0.25 мс
    "kernel.sched_min_granularity_ns" = 1000000;   # 1 мс
    "kernel.sched_wakeup_granularity_ns" = 2000000; # 2 мс
   #"vm.swappiness" = 10;                                  # определено через musnix
  "vm.vfs_cache_pressure" = 50;
  "vm.dirty_bytes" = 536870912;            # 512 MiB
  "vm.dirty_background_bytes" = 134217728; # 128 MiB
  "vm.stat_interval" = 10;
  "vm.dirty_writeback_centisecs" = 500;
  "vm.dirty_expire_centisecs" = 3000;
  "vm.max_map_count" = 1048576;
  };
  # ========== KSM (отключён) ==========
  hardware.ksm.enable = false;
  # ========== Аудио оптимизация (musnix) ==========
  musnix.enable = true;
  musnix.kernel.realtime = false;         # для совместимости с NVIDIA
 #musnix.snd_hda_intel.enable = false;    # раскомментируйте если нужно


  # ========== NETWORK & SYSTEM ==========
  networking.hostName = "Lucerno-PC";
  networking.networkmanager.enable = true;

  # ========== Bluetooth ==========
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  # ========== NVIDIA ==========
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.graphics = {
    enable = true;                                   # Включаем поддержку аппаратного ускорения графики
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


}
