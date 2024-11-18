{ config, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix

    ./programs/nrfutil.nix

    ./services/avahi.nix
    ./services/docker.nix
    ./services/jenkins.nix
    ./services/logiops.nix
    ./services/wstunnel.nix
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
    headless = false;
    gaming = false;
    development = true;
    creative = true;

    dataDrives = let
      main = "/data";
    in {
      drives = { inherit main; };
      default = main;
    };

    screens = {
      DP-1 = {
        primary = true;
        frequency = 60;
      };
      DP-2 = {
        frequency = 60;
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

  networking = {
    hostName = "dosei";
    networkmanager.enable = true;
    # TODO: reenable
    firewall.enable = false;
    # hostId = "";
  };

  services = {
    openssh = {
      enable = true;
      settings.X11Forwarding = true;
    };
    blueman.enable = true;
    fstrim.enable = true;
  };

  hardware = {
    bluetooth.enable = true;
    enableRedistributableFirmware = true;
    keyboard.zsa.enable = true;
  };
}
