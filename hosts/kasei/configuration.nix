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
    interfaces.wlp5s0.useDHCP = true; 
    interfaces.wlp2s0f0u4.useDHCP = true; 
    firewall.enable = true;
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

  hardware.bluetooth.enable = true;

  virtualisation = {
    docker.enable = true;
    libvirtd.enable = true;
  };
}


