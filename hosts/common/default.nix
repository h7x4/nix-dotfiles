{ config, pkgs, lib, extendedLib, ... }:
let
  inherit (config) machineVars;
in {
  imports = [
    ./fonts.nix
    ./nix.nix

    ./programs/dconf.nix
    ./programs/gnupg.nix
    ./programs/neovim.nix
    ./programs/nix-ld.nix
    ./programs/ssh.nix
    ./programs/usbtop.nix
    ./programs/wireshark.nix

    ./services/blueman.nix
    ./services/dbus.nix
    ./services/display-manager.nix
    ./services/docker.nix
    ./services/fwupd.nix
    ./services/gnome-keyring.nix
    ./services/irqbalance.nix
    ./services/journald.nix
    ./services/libinput.nix
    ./services/locate.nix
    ./services/logind.nix
    ./services/nixseparatedebuginfod.nix
    ./services/nscd.nix
    ./services/openssh.nix
    ./services/pcscd.nix
    ./services/pipewire.nix
    ./services/printing.nix
    ./services/resolved.nix
    ./services/smartd.nix
    ./services/systemd-lock-handler.nix
    ./services/udisks2.nix
    ./services/uptimed.nix
    ./services/userborn.nix
    ./services/userdbd.nix
    ./services/xserver.nix
  ];

  # systemd.enableStrictShellChecks = true;

  sops.defaultSopsFile = ./../.. + "/secrets/${config.networking.hostName}.yaml";

  time.timeZone = lib.mkDefault "Europe/Oslo";

  console = {
    font = lib.mkDefault "Lat2-Terminus16";
    keyMap = lib.mkDefault "us";
  };

  networking = {
    useDHCP = false;
    nameservers = [
      "1.1.1.1"
      "8.8.8.8"
    ];
    hosts = {
      "127.0.0.1" = [ config.networking.fqdnOrHostName ];
      "::1" = [ config.networking.fqdnOrHostName ];
    };

    nftables.enable = true;
  };

  i18n.defaultLocale = "en_US.UTF-8";

  environment = {
    variables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };

    systemPackages = with pkgs; ([
      wget
    ] ++ (lib.optionals (!config.machineVars.headless) [
      haskellPackages.xmobar
    ]));

    shells = with pkgs; [
      bashInteractive
      zsh
      dash
    ];

    etc = {
      currentSystemPackages = {
        target = "current-system-packages";
        text = let
          inherit (lib.strings) concatStringsSep;
          inherit (lib.lists) sort;
          inherit (lib.trivial) lessThan;
          packages = map (p: "${p.name}") config.environment.systemPackages;
          sortedUnique = sort lessThan (lib.unique packages);
        in concatStringsSep "\n" sortedUnique;
      };
    };

    shellAliases.fixdisplay = let
      inherit (config.machineVars) screens headless fixDisplayCommand;

      screenToArgs = name: screen: with screen;
        "--output ${name} --mode ${resolution} --rate ${toString frequency} --pos ${position}"
        + (lib.optionalString primary " --primary");

      screenArgs = lib.concatStringsSep " " (lib.mapAttrsToList screenToArgs screens);

    in lib.mkIf (!headless)
      (if screenArgs != null
          then "xrandr ${screenArgs}"
          else (lib.mkIf (fixDisplayCommand != null) fixDisplayCommand));
  };

  users = {
    users.h7x4 = {
      isNormalUser = true;
      shell = pkgs.zsh;
      uid = 1000;

      extraGroups = [
        "audio"
        "disk"
        "docker"
        "input"
        "libvirtd"
        "lp"
        "media"
        "minecraft"
        "networkmanager"
        "rtkit"
        "scanner"
        "video"
        "wheel"
        "wireshark"
      ];
    };

    groups = {
      adbusers.members = [ "h7x4" ];
    };
  };

  services = {
    udev.packages = with pkgs; [
      yubikey-personalization
      android-udev-rules
      light
    ];
  };

  programs = {
    dconf.enable = !config.machineVars.headless;
    git.enable = true;
    tmux.enable = true;
    zsh.enable = true;
    hyprland = lib.mkIf config.machineVars.wayland {
      enable = true;
      withUWSM = true;
    };
  };

  security.pam.services = lib.mkIf (config.machineVars.wayland) {
    hyprlock = { };
  };

  system.extraDependencies =
    lib.optionals (config.machineVars.development) (with pkgs; [
      asciidoc
      asciidoctor
      cabal2nix
      clang
      dart
      dotnet-sdk
      # dotnet-sdk_3
      # dotnet-sdk_5
      dotnetPackages.Nuget
      elm2nix
      elmPackages.elm
      flutter
      gcc
      ghc
      ghcid
      # haskellPackages.Cabal_3_6_3_0
      maven
      nixfmt-rfc-style
      nixpkgs-fmt
      # nixpkgs-hammering
      nodePackages.node2nix
      nodePackages.npm
      nodePackages.sass
      nodePackages.typescript
      nodePackages.yarn
      nodejs
      plantuml
      python3
      rustc
      rustc
      rustup
      sqlcheck
      sqlint
      sqlite
      sqlite-web
    ]);

  # Realtime scheduling for pipewire and mpd
  security.rtkit.enable = !config.machineVars.headless;

  systemd.tpm2.enable = true;
  security.tpm2 = {
    enable = lib.mkDefault true;
    abrmd.enable = lib.mkDefault config.security.tpm2.enable;
    pkcs11.enable = lib.mkDefault config.security.tpm2.enable;
    tctiEnvironment = {
      enable = lib.mkDefault config.security.tpm2.enable;
      interface = "tabrmd";
    };
  };

  # security.lockKernelModules = true;
  security.protectKernelImage = true;

  security.sudo.extraConfig = let
    sudoLecture = pkgs.writeText "sudo-lecture.txt" (extendedLib.termColors.front.red "Be careful or something, idk...\n");
  in ''
    Defaults    lecture = always
    Defaults    lecture_file = ${sudoLecture}
  '';

  systemd = {
    sysupdate.enable = true;
    repart.enable = true;
  };

  boot = {
    kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;
    loader.systemd-boot.memtest86.enable = true;

    tmp.useTmpfs = lib.mkDefault true;

    kernel.sysctl."kernel.sysrq" = 1;

    # https://github.com/NixOS/nixpkgs/blob/nixos-24.05/nixos/modules/profiles/hardened.nix
    blacklistedKernelModules = [
      # Obscure network protocols
      "ax25"
      "netrom"
      "rose"

      # Old or rare or insufficiently audited filesystems
      "adfs"
      "affs"
      "bfs"
      "befs"
      "cramfs"
      "efs"
      # "erofs" // used by systemd
      "exofs"
      "freevxfs"
      "f2fs"
      "hfs"
      "hpfs"
      "jfs"
      "minix"
      "nilfs2"
      "ntfs"
      "omfs"
      "qnx4"
      "qnx6"
      "sysv"
      "ufs"
    ];
  };

  hardware.bluetooth = {
    powerOnBoot = true;
    settings = {
      General = {
        Enable = "Source,Sink,Media,Socket";
      };
    };
  };
}
