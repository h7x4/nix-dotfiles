{ config, lib, pkgs, inputs, specialArgs, ... }:
{
  imports = [
    ./services/avahi.nix
    ./services/btrfs.nix
    ./services/docker.nix
    ./services/libvirtd.nix
    ./services/logiops.nix
    ./services/postgres.nix
    ./services/stable-diffusion.nix
    ./services/tailscale.nix
    ./services/keybase.nix

    ./nspawn-containers/arch.nix

    ./testconfig.nix
  ];

  system.stateVersion = "25.05";

  boot.binfmt.emulatedSystems = [
    "x86_64-windows"
    "aarch64-linux"
    "armv7l-linux"
    "i686-linux"
  ];

  nix.settings.system-features = [
    "kvm"
    "benchmark"
    "big-parallel"
    "nixos-test"
  ];

  i18n.extraLocaleSettings = {
    LC_ALL = "en_US.UTF-8";
  };

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

  systemd.network = {
    enable = true;
    networks."40-enp6s0" = {
      gateway = [ "192.168.50.1" ];
      address = [ "192.168.50.200/24" ];
      networkConfig.IPv6AcceptRA = "no";
      DHCP = "yes";
    };
  };

  networking = {
    hostName = "kasei";
    useNetworkd = true;
    interfaces.enp6s0.useDHCP = true;
    firewall.enable = false;
    hostId = "f0660cef";
  };

  services = {
    openssh.enable = true;
    xserver.videoDrivers = [ "nvidia" ];
    tailscale.enable = true;
    avahi = {
      enable = true;
      publish.enable = true;
      publish.addresses = true;
      publish.domain = true;
      publish.hinfo = true;
      publish.userServices = true;
      publish.workstation = true;
      extraServiceFiles.ssh = "${pkgs.avahi}/etc/avahi/services/ssh.service";
    };
  };

  boot = {
    initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod" "sr_mod" ];

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
    sane.enable = true;

    nvidia = {
      modesetting.enable = true;
      open = false;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.beta;
    };
  };
}
