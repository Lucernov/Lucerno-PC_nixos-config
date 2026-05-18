{ config, pkgs, lib, modulesPath, ... }:

let
  # UUID дисков
  bootUUID = "59A7-C7F6";
  sysUUID = "1964f286-7b1d-40df-8201-5824671e9631";
  sysBackupUUID = "67a25908-e1e2-4e53-a04b-909418c0eff8";     # второй раздел системного диска @nixos-config, @ai, @sys-archiv

  gamesUUID = "897f0999-d31e-45d1-b186-6822c7d17477";
  musicUUID = "3615f1b6-bb2e-4254-b795-f08e9a542523";
  dataUUID = "09024d77-6155-4db0-ae3c-5655858a83ad";          # 1.8TB общий для всех подтомов btrfs
in

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  services.udev.extraRules = ''
    # Все SSD и NVMe
    ACTION=="add|change", KERNEL!="zram*", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="kyber"
    # Все HDD
    ACTION=="add|change", ATTR{queue/rotational}=="1", ATTR{queue/scheduler}="mq-deadline"
    # NVMe диск для игр
    ACTION=="add|change", KERNEL=="nvme0n1", ATTR{bdi/read_ahead_kb}="512"
    # HDD — read-ahead 1024 KB
    ACTION=="add|change", ATTR{queue/rotational}=="1", ATTR{bdi/read_ahead_kb}="1024"
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
  fileSystems."/home/lucerno/nixos-config" = {
    device = "/dev/disk/by-uuid/${sysBackupUUID}";
    fsType = "btrfs";
    options = [ "subvol=@nixos-config" "compress=zstd" "noatime" "space_cache=v2" "ssd" ];
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


  swapDevices = [ ];
  # ========== ВИРТУАЛЬНЫЙ ДИСК Zram0 ==========
  zramSwap = {
    enable = true;
    memoryPercent = 25;       # Размер zram-устройства в процентах от общего объёма RAM (1/4 = 25%)
    algorithm = "lz4";
    priority = 100;
  };
# Однако, поскольку ZRAM уже включен и отлично работает, у вас нет необходимости его менять. Он обеспечивает потрясающую скорость и защищает ваш SSD от износа. Но если в будущем вы обнаружите, что игровой процесс стал не таким плавным при заполненной памяти, имеет смысл рассмотреть переход на ZSWAP для более эффективного распределения ресурсов.

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
  # ========== КОНЕЦ РАЗДЕЛА ДИСКОВ ==========


  # ========== Обновление микрокода процессора i5 13400f и прошивок ==========
  hardware.cpu.intel.updateMicrocode = true;
  hardware.enableRedistributableFirmware = true;
  services.fwupd.enable = true;


  # ========== ЯДРО И ЕГО МОДУЛИ ==========
  boot.kernelPackages = pkgs.linuxPackages_6_18;
  boot.kernelModules = [ "kvm-intel" "ntsync" "nvidia_uvm" ];          # Автозагрузка модуля NTSync
  boot.initrd.kernelModules = [ "nvidia" "nvidia_modeset" "nvidia_drm" ];
  boot.initrd.availableKernelModules = [ "vmd" "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" ];
  boot.extraModulePackages = [ ];
  boot.kernelParams = [
    "transparent_hugepage=madvise"
    "nvidia_drm.modeset=1"                                 # Загружаем модуль ядра NVIDIA раньше для более гладкой загрузки и Wayland
    "nvidia_drm.fbdev=1"
    "mitigations=auto"
    "threadirqs"                                           # все прерывания в потоки – для лучшего управления приоритетами
    "preempt=full"                                         # полное вытеснение ядра – снижает задержки
    "rcupdate.rcu_cpu_stall_timeout=60"
    "usbcore.autosuspend=-1"                               # usb устройства не засыпают
    "clocksource=tsc"
    "tsc=reliable"
    "irqaffinity=0"                                        # перенаправить все IRQ на ядро 0
    "nowatchdog"
    "mce=ignore_ce"
  ];

  # ========== Тонкая настройка ядра (sysctl) ==========
  boot.kernel.sysctl = {
    "kernel.sched_autogroup_enabled" = 0;
    "kernel.sched_base_slice_ns" = 2000000;                # 2 мс
   #"vm.swappiness" = 10;                                  # определено через musnix
    "vm.vfs_cache_pressure" = 50;
    "vm.dirty_bytes" = 536870912;                          # 512 MiB
    "vm.dirty_background_bytes" = 134217728;               # 128 MiB
    "vm.stat_interval" = 10;
    "vm.dirty_writeback_centisecs" = 500;
    "vm.dirty_expire_centisecs" = 3000;
    "vm.max_map_count" = 1048576;
  };
  # ========== KSM (отключён) ==========
  hardware.ksm.enable = false;


  # ========== NETWORK & SYSTEM ==========
  networking.hostName = "Lucerno-PC";
  networking.networkmanager.enable = true;
  #networking.networkmanager.wifi.backend = "iwd";


  # ========== Bluetooth ==========
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };


  # ========== NVIDIA RTX 3070 ==========
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.graphics = {
    enable = true;                                               # Включаем поддержку аппаратного ускорения графики
    enable32Bit = true;
    extraPackages = with pkgs; [ nvidia-vaapi-driver ];
  };
  # Настройка драйвера NVIDIA для Wayland
  hardware.nvidia = {
    open = true;                                                 # Используем открытые модули (для RTX 3070 это работает)
    modesetting.enable = true;                                   # Обязательно для Wayland: включает режим "Sync & Destroy"
    nvidiaSettings = true;                                       # Устанавливает утилиту nvidia-settings
    powerManagement.enable = false;                              # Отключаем управление питанием (на десктопе не нужно, только для ноутбуков)
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };



  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
