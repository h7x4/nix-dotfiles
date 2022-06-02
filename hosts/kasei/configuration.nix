{ config, lib, pkgs, inputs, specialArgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../pluggables/tools/programming.nix
  ];

  systemd.targets = {
    sleep.enable = false;
    suspend.enable = false;
    hibernate.enable = false;
    hybrid-sleep.enable = false;
  };

  # security.pam.services.login.unixAuth = true;

  boot.loader = {
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

  networking = {
    hostName = "kasei";
    networkmanager.enable = true;
    useDHCP = false;
    interfaces.wlp5s0.useDHCP = true; 
    interfaces.wlp2s0f0u4.useDHCP = true; 
    nameservers = [
      "1.1.1.1"
      "8.8.8.8"
    ];
    firewall.enable=true;
  };

  environment = {
    shellAliases = {
      fixscreen = "xrandr --output DP-4 --mode 1920x1080 --pos 0x0 -r 144 --output DVI-D-1 --primary --mode 1920x1080 --pos 1920x0 -r 60";
    };
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

  virtualisation = {
    docker.enable = true;
    libvirtd.enable = true;
  };
}


