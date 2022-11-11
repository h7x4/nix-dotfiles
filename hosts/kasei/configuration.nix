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

    fixDisplayCommand = "xrandr --output DP-4 --mode 1920x1080 --pos 0x0 -r 144 --output HDMI-0 --primary --mode 1920x1080 --pos 1920x0 -r 60";

    # screens = {
    #   "DP-1" = {};
    #   "HDMI-1" = {};
    # };
  };

  systemd.targets = {
    sleep.enable = false;
    suspend.enable = false;
    hibernate.enable = false;
    hybrid-sleep.enable = false;
  };

  # security.pam.services.login.unixAuth = true;

  boot = {
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

  networking = {
    hostName = "kasei";
    networkmanager.enable = true;
    interfaces.wlp2s0f0u7u3.useDHCP = true;
    firewall.enable = true;
  };

  services = {
    openssh.enable = true;
    printing.enable = true;
    cron = {
      enable = true;
      systemCronJobs = [
    #     "*/5 * * * *      root    date >> /tmp/cron.log"
      ];
    };
  };

  hardware.bluetooth.enable = true;

  virtualisation = {
    docker.enable = true;
    libvirtd.enable = true;
  };
}


