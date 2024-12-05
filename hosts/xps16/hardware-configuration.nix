# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "thunderbolt" "vmd" "nvme" "usbhid" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/178502e0-0481-47ed-842c-2d6b1cf81ac5";
      fsType = "btrfs";
      options = [ "subvol=root" "compress=zstd" "noatime" ];
    };

  boot.initrd.luks.devices."crypted".device = "/dev/disk/by-uuid/88bbd92a-88b5-4175-9d6f-c14033607b70";
  
  fileSystems."/boot" =
  { device = "/dev/disk/by-uuid/34BA-6EA6";
    fsType = "vfat";
  };

  fileSystems."/home/h7x4" =
    { device = "/dev/disk/by-uuid/178502e0-0481-47ed-842c-2d6b1cf81ac5";
      fsType = "btrfs";
      options = [ "subvol=home/h7x4/active" "compress=zstd" "noatime" ];
    };

  fileSystems."/home/h7x4/.snapshots" =
    { device = "/dev/disk/by-uuid/178502e0-0481-47ed-842c-2d6b1cf81ac5";
      fsType = "btrfs";
      options = [ "subvol=home/h7x4/snapshots" "compress=zstd" "noatime" ];
    };

  fileSystems."/home/h7x4/git" =
    { device = "/dev/disk/by-uuid/178502e0-0481-47ed-842c-2d6b1cf81ac5";
      fsType = "btrfs";
      options = [ "subvol=home/h7x4/git/active" "compress=zstd" "noatime" ];
    };

  fileSystems."/home/h7x4/ctf" =
    { device = "/dev/disk/by-uuid/178502e0-0481-47ed-842c-2d6b1cf81ac5";
      fsType = "btrfs";
      options = [ "subvol=home/h7x4/ctf/active" "compress=zstd" "noatime" ];
    };

  fileSystems."/home/h7x4/downloads" =
    { device = "/dev/disk/by-uuid/178502e0-0481-47ed-842c-2d6b1cf81ac5";
      fsType = "btrfs";
      options = [ "subvol=home/h7x4/downloads/active" "compress=zstd" "noatime" ];
    };

  fileSystems."/home/h7x4/pictures" =
    { device = "/dev/disk/by-uuid/178502e0-0481-47ed-842c-2d6b1cf81ac5";
      fsType = "btrfs";
      options = [ "subvol=home/h7x4/pictures/active" "compress=zstd" "noatime" ];
    };

  fileSystems."/home/h7x4/music" =
    { device = "/dev/disk/by-uuid/178502e0-0481-47ed-842c-2d6b1cf81ac5";
      fsType = "btrfs";
      options = [ "subvol=home/h7x4/music/active" "compress=zstd" "noatime" ];
    };

  fileSystems."/home/h7x4/music/.snapshots" =
    { device = "/dev/disk/by-uuid/178502e0-0481-47ed-842c-2d6b1cf81ac5";
      fsType = "btrfs";
      options = [ "subvol=home/h7x4/music/snapshots" "compress=zstd" "noatime" ];
    };

  fileSystems."/var/log" =
    { device = "/dev/disk/by-uuid/178502e0-0481-47ed-842c-2d6b1cf81ac5";
      fsType = "btrfs";
      options = [ "subvol=var/log/active" "compress=zstd" "noatime" ];
    };

  fileSystems."/var/log/.snapshots" =
    { device = "/dev/disk/by-uuid/178502e0-0481-47ed-842c-2d6b1cf81ac5";
      fsType = "btrfs";
      options = [ "subvol=var/log/snapshots" "compress=zstd" "noatime" ];
    };

  fileSystems."/var/lib" =
    { device = "/dev/disk/by-uuid/178502e0-0481-47ed-842c-2d6b1cf81ac5";
      fsType = "btrfs";
      options = [ "subvol=var/lib/active" "compress=zstd" "noatime" ];
    };

  fileSystems."/var/lib/.snapshots" =
    { device = "/dev/disk/by-uuid/178502e0-0481-47ed-842c-2d6b1cf81ac5";
      fsType = "btrfs";
      options = [ "subvol=var/lib/snapshots" "compress=zstd" "noatime" ];
    };

  fileSystems."/var/lib/docker" =
    { device = "/dev/disk/by-uuid/178502e0-0481-47ed-842c-2d6b1cf81ac5";
      fsType = "btrfs";
      options = [ "subvol=var/lib/docker" "compress=zstd" "noatime" ];
    };

  swapDevices = [ ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp0s13f0u1u4.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp2s0f0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}