{ config, lib, pkgs, inputs, specialArgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
  ];

  services.xserver.enable = true;
  services.xserver.videoDrivers = ["nvidia"];

  # TODO: See ../common.nix
  services.xserver.displayManager.lightdm.enable = true;

  machineVars = {
    headless = false;
    gaming = true;
    development = true;
    creative = true;

    wlanInterface = "wlp2s0f0u7u3";

    dataDrives = let
      main = "/data";
    in {
      drives = { inherit main; };
      default = main;
    };

    screens = {
      DP-4 = {
        primary = true;
        frequency = 144;
      };
      HDMI-0 = {
        position = "1920x0";
      };
    };
  };

  systemd.targets = {
    sleep.enable = false;
    suspend.enable = false;
    hibernate.enable = false;
    hybrid-sleep.enable = false;
  };

  # security.pam.services.login.unixAuth = true;

  # TODO: remove when merged: https://github.com/NixOS/nixpkgs/pull/167388
  systemd.services.logid = {
    description = "Logitech Configuration Daemon";
    startLimitIntervalSec = 0;
    wants = [ "multi-user.target" ];
    after = [ "multi-user.target" ];
    wantedBy = [ "graphical-session.target" ];

    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.logiops}/bin/logid";
      User = "root";
      ExecReload = "/bin/kill -HUP $MAINPID";
      Restart="on-failure";
    };
  };

  virtualisation = {
    docker.enable = true;
    libvirtd.enable = true;
  };

  boot = {
    initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod" "sr_mod" ];
    initrd.kernelModules = [ ];
    kernelModules = [ "kvm-amd" ];
    blacklistedKernelModules = ["nouveau"];
    kernelParams = ["nomodeset"];
    loader = {
      efi.canTouchEfiVariables = false;
      grub = {
        enable = true;
        version = 2;
        efiSupport = true;
        fsIdentifier = "label";
        device = "nodev";
        efiInstallAsRemovable = true;
      };
    };
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/70a0ca95-4ca4-4298-a8c4-e492705cfb93";
      fsType = "btrfs";
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/D883-A077";
      fsType = "vfat";
    };

    "/data" = {
      device = "/dev/disk/by-label/data1";
      fsType = "btrfs";
    };

    "/data/disks/data2" = {
      device = "/dev/disk/by-uuid/7afc5f6b-947a-4c86-a5b5-dfefe42899c0";
      fsType = "ext4";
    };
  };

  swapDevices = [ ];

  hardware = {
    bluetooth.enable = true;
    cpu.amd.updateMicrocode = true;
    enableRedistributableFirmware = true;
    keyboard.zsa.enable = true;
    logitech.wireless.enable = true;
  };
}


