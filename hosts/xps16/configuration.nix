{ config, lib, pkgs, inputs, specialArgs, ... }:
{
  imports = [
    ./hardware-configuration.nix

    ./services/btrfs.nix
    ./services/docker.nix
    ./services/fprintd.nix
    ./services/keybase.nix
    ./services/libvirtd.nix
    ./services/logiops.nix
    ./services/tailscale.nix
    ./services/thermald.nix
    ./services/tlp.nix

    ./machines

    ./testconfig.nix
  ];

  programs.adb.enable = true;

  sops.age.keyFile = "/var/lib/sops/age-key.txt";

  system.stateVersion = "24.11";

  boot.kernelPackages = pkgs.linuxPackages_6_15;

  boot.loader = {
    efi.canTouchEfiVariables = true;
    systemd-boot.enable = true;
    systemd-boot.consoleMode = "1";
  };

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

  environment.enableDebugInfo = true;

  i18n.extraLocaleSettings = {
    LC_ALL = "en_US.UTF-8";
  };

  console = {
    earlySetup = true;
    font = "${pkgs.terminus_font}/share/consolefonts/ter-132n.psf.gz";
    packages = with pkgs; [ terminus_font ];
  };

  machineVars = {
    headless = false;
    gaming = true;
    development = true;
    creative = true;
    wayland = true;
  };

  networking = {
    hostName = "xps16";
    networkmanager.enable = true;
    firewall.enable = true;
    # hostId = "f0660cef";
  };

  services = {
    xserver.upscaleDefaultCursor = true;
    xserver.dpi = 192;
    xserver.videoDrivers = [ "displaylink" "modesetting" ];
    displayManager.sddm = {
      enableHidpi = true;
      settings = {
        X11.ServerArguments = "-nolisten tcp -dpi 192";
      };
    };
    libinput.touchpad.accelSpeed = "0.5";
    blueman.enable = true;
  };

  hardware = {
    bluetooth.enable = true;
    enableRedistributableFirmware = true;
    keyboard.zsa.enable = true;
    sane.enable = true;
    graphics = {
      enable = true;
      enable32Bit = true;
    };
    ipu6 = {
      enable = true;
      platform = "ipu6epmtl";
    };
  };
}
