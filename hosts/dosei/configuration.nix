{ config, pkgs, lib, ... }:
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

  boot.kernelPackages = pkgs.linuxPackages_6_14;

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

    wayland = true;

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

  systemd.network = {
    enable = true;
    networks."40-enp0s31f6" = {
      name = "enp0s31f6";
      DHCP = true;
      domains = [ "nordicsemi.no" ];
    };
  };

  networking = {
    hostName = "dosei";
    useNetworkd = true;
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

  nix.buildMachines = lib.mkForce [ ];

  hardware = {
    bluetooth.enable = true;
    enableRedistributableFirmware = true;
    keyboard.zsa.enable = true;
  };
}
