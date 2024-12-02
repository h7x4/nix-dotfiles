{ config, pkgs, lib, extendedLib, ... }:
let
  inherit (config) machineVars;
in {
  imports = [
    ./fonts.nix
    ./nix.nix

    ./programs/gnupg.nix
    ./programs/neovim.nix
    ./programs/nix-ld.nix
    ./programs/ssh.nix
    ./programs/usbtop.nix

    ./services/dbus.nix
    ./services/openssh.nix
    ./services/pcscd.nix
    ./services/pipewire.nix
    ./services/printing.nix
    ./services/resolved.nix
    ./services/smartd.nix
    ./services/systemd-lock-handler.nix
    ./services/uptimed.nix
    ./services/xserver.nix
  ];

  # systemd.enableStrictShellChecks = true;

  sops.defaultSopsFile = ./../.. + "/secrets/${config.networking.hostName}.yaml";

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
    gnome.gnome-keyring.enable = !config.machineVars.headless;

    udev.packages = with pkgs; [
      yubikey-personalization
      android-udev-rules
      light
    ];

    libinput = {
      enable = !config.machineVars.headless;
      touchpad.disableWhileTyping = true;
    };

    irqbalance.enable = true;

    displayManager.defaultSession = "none+xmonad";
  };

  programs = {
    dconf.enable = !config.machineVars.headless;
    git.enable = true;
    tmux.enable = true;
    zsh.enable = true;
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

  security.rtkit.enable = !config.machineVars.headless;

  security.sudo.extraConfig = let
    sudoLecture = pkgs.writeText "sudo-lecture.txt" (extendedLib.termColors.front.red "Be careful or something, idk...\n");
  in ''
    Defaults    lecture = always
    Defaults    lecture_file = ${sudoLecture}
  '';
}
