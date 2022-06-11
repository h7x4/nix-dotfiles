{ pkgs, config, ... }: let
  # FIXME: lib should be imported directly as a module argument.
  inherit (pkgs) lib;

# TODO: Split this file
in {
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

  boot.loader = {
    efi.canTouchEfiVariables = false;
    grub = {
      enable = true;
      device = "/dev/sda";
      version = 2;
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

  i18n = {
    inputMethod = {
      enabled = "fcitx";
      fcitx.engines = with pkgs.fcitx-engines; [ mozc ];
    };

    # inputMethod = {
    #   enabled = "fcitx5";
    #   fcitx5.addons = with pkgs; [
    #     fcitx5-mozc
    #     fcitx5-gtk
    #   ];
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

  hardware.bluetooth.enable = true;

  virtualisation = {
    docker.enable = true;
    # libvirtd.enable = true;
  };
}

