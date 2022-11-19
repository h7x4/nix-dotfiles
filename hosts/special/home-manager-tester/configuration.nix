{ pkgs, lib, config, ... }:
# lib.trace lib.version
# (lib.trace lib
{
  # KASEI SPECIFIC STUFF

  imports = [
    ../../kasei/hardware-configuration.nix
  ];

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


  # HOME-MANAGER MODULE

  home-manager = builtins.trace pkgs.lib.version {
    # useGlobalPkgs = true;

    users.h7x4 = import ./home.nix {
      inherit pkgs;
    };
  };

  # DEFAULT MACHINE CONFIG

  nixpkgs.config.allowUnfree = true;

  nix = {
    settings = {
      substituters = [
        "https://cache.nixos.org/"
      ];

      trusted-users = [ "h7x4" "nix-builder" ];
    };

    extraOptions = ''
      experimental-features = nix-command flakes
      builders-use-substitutes = true
      allowed-uris = http:// https://
    '';
  };

  time.timeZone = "Europe/Oslo";

  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  networking = {
    useDHCP = false;
    nameservers = [
      "1.1.1.1"
      "8.8.8.8"
    ];
  };

  i18n = {
    defaultLocale = "en_US.UTF-8";
    # inputMethod = lib.mkIf (!machineVars.headless) {
    #   enabled = "fcitx";
    #   fcitx.engines = with pkgs.fcitx-engines; [ mozc ];
    # };

    inputMethod = {
      enabled = "fcitx5";
      fcitx5.addons = with pkgs; [
        fcitx5-mozc
        fcitx5-gtk
      ];
    };
  };

  environment = {
    variables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };

    systemPackages = with pkgs; [
      wget
      nvtop-nvidia
    ];

    shells = with pkgs; [
      bashInteractive
      zsh
    ];

    etc = {
      "resolv.conf".source = let
        inherit (lib.strings) concatStringsSep;
        inherit (pkgs) writeText;
      in writeText "resolv.conf" ''
        ${concatStringsSep "\n" (map (ns: "nameserver ${ns}") config.networking.nameservers)}
        options edns0
      '';
    };
  };

  fonts.enableDefaultFonts = true;

  users = {
    users.h7x4 = {
      isNormalUser = true;
      shell = pkgs.zsh;

      extraGroups = [
        "wheel"
        "networkmanager"
      ];
    };
  };

  services = {
    dbus.enable = true;

    xserver = {
      enable = true;
      layout = "us";
      xkbOptions = "caps:escape";

      desktopManager = {
        xterm.enable = false;
        xfce.enable = true;
      };
    };
  };

  programs = {
    git.enable = true;
    neovim = {
      enable = true;
      defaultEditor = true;
    };
  };

  sound = {
    enable = true;
    mediaKeys.enable = true;
  };

  hardware.pulseaudio.enable = true;

  system.stateVersion = "22.05";
}
