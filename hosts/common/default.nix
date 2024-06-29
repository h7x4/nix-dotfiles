{ pkgs, unstable-pkgs, lib, extendedLib, config, inputs, secrets, ... }:
let
  inherit (config) machineVars;
in {
  imports = [
    ./nix-builders/bob.nix
    ./nix-builders/isvegg.nix
    ./nix-builders/tsuki.nix
  ];

  sops.defaultSopsFile = ./../.. + "/secrets/${config.networking.hostName}.yaml";

  sops.secrets = {
    "nix/access-tokens" = { sopsFile = ./../../secrets/common.yaml; };

    "ssh/secret-config/global" = {
      sopsFile = ./../../secrets/common.yaml;
      mode = "0444";
    };
  };

  nix = {
    package = unstable-pkgs.nixVersions.stable;
    distributedBuilds = config.networking.hostName != "tsuki";

    settings = {
      allow-dirty = true;
      allowed-uris = [ "http://" "https://" ];
      auto-optimise-store = true;
      binary-caches = [ "https://cache.nixos.org/" ];
      builders-use-substitutes = true;
      experimental-features = [ "nix-command" "flakes" ];
      log-lines = 50;
      trusted-users = [ "h7x4" "nix-builder" ];
      use-xdg-base-directories = true;
    };

    extraOptions = ''
      !include ${config.sops.secrets."nix/access-tokens".path}
    '';

    registry = {
      home.to = {
        type = "path";
        path = "/home/h7x4/nix";
      };
      wack.to = {
        type = "path";
        path = "/home/h7x4/git/wack-ctf-flake";
      };
      nxpt.to = {
        type = "path";
        path = "/home/h7x4/git/nixpkgs-tools";
      };
    };
  };

  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      libusb1
    ];
  };

  programs.ssh = {
    extraConfig = ''
      Include ${config.sops.secrets."ssh/secret-config/global".path}
    '';

    knownHosts = {
      bob = {
        hostNames = [
          "bob.pvv.ntnu.no"
          "bob.pvv.org"
        ];
        publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGJSgh20qDIYEXiK4MUZhc879dJIyH0K/s0RZ+9wFI0F";
      };
      hildring = {
        hostNames = [
          "hildring.pvv.ntnu.no"
          "hildring.pvv.org"
          "login.pvv.ntnu.no"
          "login.pvv.org"
        ];
        publicKey = "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBGurF7rdnrDP/VgIK2Tx38of+bX/QGCGL+alrWnZ1Ca5llGneMulUt1RB9xZzNLHiaWIE+HOP0i4spEaeZhilfU=";
      };
      isvegg = {
        hostNames = [
          "isvegg.pvv.ntnu.no"
          "isvegg.pvv.org"
        ];
        publicKey = "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBGurF7rdnrDP/VgIK2Tx38of+bX/QGCGL+alrWnZ1Ca5llGneMulUt1RB9xZzNLHiaWIE+HOP0i4spEaeZhilfU=";
      };
    #   tsukir = {
    #     hostNames = [ "nani.wtf" "gingakei.loginto.me" ];
    #     # publicKeyFile = config.sops.secrets."ssh/nix-builders/tsuki/pub".path;
    #     publicKeyFile = "/var/keys/tsuki_nix-builder.pub";
    #   };
    };
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

  fonts = {
    fontDir.enable = true;

    enableDefaultPackages = true;
    packages = with pkgs; [
      ark-pixel-font
      cm_unicode
      corefonts
      dejavu_fonts
      fira-code
      fira-code-symbols
      iosevka
      ipaexfont
      ipafont
      liberation_ttf
      migmix
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-emoji
      ocr-a
      open-sans
      powerline-fonts
      source-han-sans
      source-sans
      symbola
      texlivePackages.asana-math
      ubuntu_font_family
      victor-mono
      yasashisa-gothic
      (nerdfonts.override { fonts = [ "FiraCode" "DroidSansMono" ]; })
    ];

    fontconfig = {
      defaultFonts = {
        serif = [ "Droid Sans Serif" "Ubuntu" ];
        sansSerif = [ "Droid Sans" "Ubuntu" ];
        monospace = [ "Fira Code" "Ubuntu" ];
        emoji = [ "Noto Sans Emoji" ];
      };
    };
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
        "media"
        "minecraft"
        "networkmanager"
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
    tumbler.enable = !config.machineVars.headless;
    gnome.gnome-keyring.enable = !config.machineVars.headless;

    resolved.enable = true;

    openssh = {
      startWhenNeeded = true;
      settings = {
        StreamLocalBindUnlink = true;
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        PermitRootLogin = "no";
      };
    };

    udev.packages = with pkgs; [
      yubikey-personalization
      android-udev-rules
      light
    ];

    pcscd.enable = true;

    dbus = {
      enable = true;
      packages = with pkgs; [
        gcr
        dconf
      ];
    };

    libinput = {
      enable = !config.machineVars.headless;
      touchpad.disableWhileTyping = true;
    };

    displayManager.defaultSession = "none+xmonad";

    xserver = {
      enable = !config.machineVars.headless;

      xkb = {
        layout = "us";
        options = "caps:escape";
      };

      desktopManager = {
        xterm.enable = false;
        xfce.enable = !config.machineVars.headless;
      };

      displayManager.lightdm.enable = !config.machineVars.headless;

      windowManager.xmonad = {
        enable = true;
        enableContribAndExtras = true;
        enableConfiguredRecompile = true;
        extraPackages = hPkgs: with hPkgs; [
          dbus
        ];
      };

    };

  };

  programs = {
    dconf.enable = !config.machineVars.headless;
    git.enable = true;
    tmux.enable = true;
    zsh.enable = true;

    gnupg.agent.enable = true;
    gnupg.agent.pinentryPackage = pkgs.pinentry-curses;

    neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
      configure = {
        packages.myVimPackage = with pkgs.vimPlugins; {
          start = [
            direnv-vim
            vim-nix
            vim-polyglot
          ];

          opt = [
            vim-monokai
          ];
        };

        customRC = ''
          set number relativenumber
          set undofile
          set undodir=~/.cache/vim/undodir

          packadd! vim-monokai
          colorscheme monokai
        '';
      };
    };
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
      nixfmt
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
  services.pipewire = {
    enable = !config.machineVars.headless;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  security.sudo.extraConfig = let
    sudoLecture = pkgs.writeText "sudo-lecture.txt" (extendedLib.termColors.front.red "Be careful or something, idk...\n");
  in ''
    Defaults    lecture = always
    Defaults    lecture_file = ${sudoLecture}
  '';
}
