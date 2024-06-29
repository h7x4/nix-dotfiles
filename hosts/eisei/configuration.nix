{ pkgs, config, ... }: let
  # FIXME: lib should be imported directly as a module argument.
  inherit (pkgs) lib;

# TODO: Split this file
in {
  imports = [
    ./hardware-configuration.nix
  ];

  # TODO: See ../common/default.nix
  services.xserver.enable = true;
  services.xserver.displayManager.lightdm.enable = true;

  machineVars = {
    gaming = true;
    creative = true;
    development = true;

    headless = false;
    laptop = true;

    screens."eDP-1".primary = true;
  };

  systemd.targets = {
    sleep.enable = false;
    suspend.enable = false;
    hibernate.enable = false;
    hybrid-sleep.enable = false;
  };

  boot.loader = {
    efi.canTouchEfiVariables = false;
    grub = {
      enable = true;
      device = "/dev/sda";
    };
  };

  networking = {
    hostName = "Eisei";
    networkmanager.enable = true;

    interfaces = {
      eno1.useDHCP = true;
      wlo1.useDHCP = true;
    };

    # firewall = {
    #   enable = false;
    #   allowedTCPPorts = [ ... ];
    #   allowedUDPPorts = [ ... ];
    # };
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

  hardware.bluetooth.enable = false;
}

