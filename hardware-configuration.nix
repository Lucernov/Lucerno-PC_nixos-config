# Это конфигурация для Btrfs с подтомами @, @nix, @home
# Создана вручную для SSD (INTEL SSDSC2BB80)
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "vmd" "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/1964f286-7b1d-40df-8201-5824671e9631";
    fsType = "btrfs";
    options = [ "subvol=@" "compress=zstd" "noatime" "space_cache=v2" "ssd" ];
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/1964f286-7b1d-40df-8201-5824671e9631";
    fsType = "btrfs";
    options = [ "subvol=@nix" "compress=zstd" "noatime" "space_cache=v2" "ssd" ];
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/1964f286-7b1d-40df-8201-5824671e9631";
    fsType = "btrfs";
    options = [ "subvol=@home" "compress=zstd" "noatime" "space_cache=v2" "ssd" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/59A7-C7F6";
    fsType = "vfat";
    options = [ "fmask=0077" "dmask=0077" ];
  };

  swapDevices = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}

