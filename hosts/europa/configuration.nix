{ config, pkgs, lib, ... }:
{
  imports = [
    ./hardware-configuration.nix

    ./services/avahi.nix
    ./services/docker.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.binfmt.emulatedSystems = [
    "aarch64-linux"
    "armv7l-linux"
  ];

  i18n.defaultLocale = "en_US.UTF-8";

  services.udev.packages = with pkgs; [
    segger-jlink
  ];

  system.stateVersion = "24.05";

  machineVars = {
    headless = true;
    gaming = false;
    development = true;
    creative = false;

    dataDrives = let
      main = "/data";
    in {
      drives = { inherit main; };
      default = main;
    };
  };

  systemd.targets = {
    sleep.enable = false;
    suspend.enable = false;
    hibernate.enable = false;
    hybrid-sleep.enable = false;
  };

  # security.pam.services.login.unixAuth = true;

  # systemd.network = {
  #   enable = true;
  #   # broken
  #   wait-online.enable = true;
  # };

  networking = {
    hostName = "europa";
    networkmanager.enable = true;
    # TODO: reenable
    firewall.enable = false;
    # hostId = "007f0201";
  };

  services = {
    openssh = {
      enable = true;
      settings.X11Forwarding = true;
      settings.PasswordAuthentication = lib.mkForce true;
    };
    # xserver = {
    #   # displayManager.gdm.enable = true;
    #   # desktopManager.gnome.enable = true;
    #   # videoDrivers = [ "nvidia" ];
    # };
    # tailscale.enable = true;
  };

  hardware = {
    bluetooth.enable = true;
    # cpu.amd.updateMicrocode = true;
    enableRedistributableFirmware = true;
    keyboard.zsa.enable = true;
    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
    };

    # nvidia = {
    #   modesetting.enable = true;
    #   nvidiaSettings = true;
    # };
  };

  programs.usbtop.enable = true;
}
