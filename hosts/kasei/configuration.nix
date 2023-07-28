{ config, lib, pkgs, inputs, specialArgs, ... }:
{
  machineVars = {
    headless = false;
    gaming = true;
    development = true;
    creative = true;

    dataDrives = let
      main = "/data";
    in {
      drives = { inherit main; };
      default = main;
    };

    screens = {
      DVI-D-0 = {
        primary = true;
      };
      DP-4 = {
        frequency = 144;
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

  networking = {
    hostName = "kasei";
    networkmanager.enable = true;
    interfaces.enp6s0.useDHCP = true;
    firewall = {
      enable = true;
      allowedTCPPorts = [ 7860 ];
      allowedUDPPorts = [ config.services.tailscale.port ];
      checkReversePath = "loose";
      trustedInterfaces = [ "tailscale0" ];
    };
    hostId = "f0660cef";
  };

  services = {
    openssh = {
      enable = true;
      settings.X11Forwarding = true;
    };
    xserver.videoDrivers = ["nvidia"];
    tailscale.enable = true;
  };

  # TODO: remove when merged: https://github.com/NixOS/nixpkgs/pull/167388
  systemd = {
    services = {
      logid = {
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
    };
  };

  virtualisation = {
    docker.enable = true;
    libvirtd.enable = true;
  };

  boot = {
    initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod" "sr_mod" ];
    initrd.kernelModules = [ ];

    # kernelPackages = pkgs.linuxKernel.packages.linux_zen.zfs;
    kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
    kernelModules = [ "kvm-amd" ];
    blacklistedKernelModules = [ "nouveau" ];
    kernelParams = [ "nomodeset" ];
    supportedFilesystems = [ "zfs" ];

    loader = {
      efi.canTouchEfiVariables = false;
      grub = {
        enable = true;
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
