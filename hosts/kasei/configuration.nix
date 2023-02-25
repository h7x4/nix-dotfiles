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


