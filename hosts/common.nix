{ pkgs, unstable-pkgs, lib, extendedLib, config, inputs, secrets, ... }:
let
  inherit (config) machineVars;
in {
  sops.defaultSopsFile = ../secrets/default.yaml;

  sops.secrets = {
    "ssh/nix-builders/tsuki/key" = { };
    "ssh/nix-builders/tsuki/pub" = { };
    "ssh/nix-builders/isvegg/key" = { };
    "ssh/nix-builders/bob/key" = { };
    # "ssh/nix-builders/isvegg/pub" = { };
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
      experimental-features = [ "nix-command" "flakes" "repl-flake" ];
      log-lines = 50;
      trusted-users = [ "h7x4" "nix-builder" ];
    };

    buildMachines = [
      # {
      #   # Login details configured in ssh module in nix-secrets
      #   hostName = "nix-builder-tsukir";
      #   system = "x86_64-linux";
      #   speedFactor = 2;
      #   maxJobs = 8;
      #   supportedFeatures = [
      #     "nixos-test"
      #     "benchmark"
      #     "big-paralell"
      #   ];
      #   mandatoryFeatures = [ ];
      #   sshUser = "nix-ssh";
      #   sshKey = config.sops.secrets."ssh/nix-builders/tsuki/key".path;
      # }
      {
        # Login details configured in ssh module in nix-secrets
        hostName = "nix-builder-isvegg";
        system = "x86_64-linux";
        speedFactor = 1;
        maxJobs = 8;
        supportedFeatures = [ ];
        mandatoryFeatures = [ ];
        sshUser = secrets.ssh.users.pvv.normalUser;
        sshKey = config.sops.secrets."ssh/nix-builders/isvegg/key".path;
      }
      {
        # Login details configured in ssh module in nix-secrets
        hostName = "nix-builder-bob";
        system = "x86_64-linux";
        speedFactor = 5;
        maxJobs = 24;
        supportedFeatures = [
          "nixos-test"
          "benchmark"
          "big-paralell"
        ];
        mandatoryFeatures = [ ];
        # sshUser = secrets.ssh.users.pvv.normalUser;
        # sshKey = config.sops.secrets."ssh/nix-builders/bob/key".path;
      }
    ];
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

  programs.ssh = {
    extraConfig = ''
      Host nix-builder-isvegg
        HostName isvegg.pvv.ntnu.no
        User oysteikt
        IdentityFile ${config.sops.secrets."ssh/nix-builders/isvegg/key".path}

      Host nix-builder-bob
        HostName bob.pvv.ntnu.no
        ProxyJump nix-builder-isvegg
        User oysteikt
        IdentityFile ${config.sops.secrets."ssh/nix-builders/bob/key".path}

      Host nix-builder-tsukir
        HostName gingakei.loginto.me
        Port ${toString secrets.ports.ssh.home-in}
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

  i18n = {
    defaultLocale = "en_US.UTF-8";
    inputMethod = lib.mkIf (!machineVars.headless) {
      # enabled = "fcitx";
      # engines = with pkgs.fcitx-engines; [ mozc ];
      enabled = "fcitx5";
      fcitx5.addons = with pkgs; [
        fcitx5-mozc
        fcitx5-gtk
        # fcitx5-chinese-addons
      ];

      fcitx5.ignoreUserConfig = true;
      fcitx5.settings.inputMethod = {
        "Groups/0" = {
          "Name" = "Default";
          "Default Layout" = "ch";
          "DefaultIM" = "mozc";
        };
        "Groups/0/Items/0" = {
          "Name" = "keybord-us";
          "Layout" = null;
        };
        "Groups/0/Items/1" = {
          "Name" = "keybord-no";
          "Layout" = null;
        };
        "Groups/0/Items/2" = {
          "Name" = "mozc";
          "Layout" = null;
        };
        "GroupOrder" = {
          "0" = "Default";
        };
      };
    };
  };

  systemd.user.services."fcitx5" = lib.mkIf (config.i18n.inputMethod.enabled == "fcitx5") {
    description = "Fcitx5 IME";
    wantedBy = [ "graphical.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${config.i18n.inputMethod.package}/bin/fcitx5";
      ExecReload = "/bin/kill -HUP $MAINPID";
      Restart="on-failure";
    };
  };

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
    enableDefaultFonts = true;

    fontDir.enable = true;

    fonts = with pkgs; [
      cm_unicode
      dejavu_fonts
      fira-code
      fira-code-symbols
      powerline-fonts
      iosevka
      symbola
      corefonts
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
      source-han-sans
      source-sans
      ubuntu_font_family
      victor-mono
      (nerdfonts.override { fonts = [ "FiraCode" "DroidSansMono" ]; })
      inputs.fonts
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
    ];

    pcscd.enable = true;

    dbus = {
      enable = true;
      packages = with pkgs; [
        gcr
        dconf
      ];
    };

    xserver = {
      enable = !config.machineVars.headless;
      layout = "us";
      xkbOptions = "caps:escape";

      libinput = {
        enable = true;
        touchpad.disableWhileTyping = true;
      };

      desktopManager = {
        xterm.enable = false;
        xfce.enable = !config.machineVars.headless;
      };

      windowManager.xmonad = {
        enable = true;
        enableContribAndExtras = true;
        enableConfiguredRecompile = true;
        extraPackages = hPkgs: with hPkgs; [
          dbus
        ];
      };

      displayManager.lightdm.enable = !config.machineVars.headless;
      displayManager.defaultSession = "none+xmonad";
    };

  };

  programs = {
    dconf.enable = !config.machineVars.headless;
    git.enable = true;
    light.enable = !config.machineVars.headless;
    npm.enable = true;
    tmux.enable = true;
    zsh.enable = true;

    gnupg.agent.enable = true;
    gnupg.agent.pinentryFlavor = "curses";

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

  sound = {
    enable = !config.machineVars.headless;
    mediaKeys.enable = true;
  };

  hardware.pulseaudio.enable = !config.machineVars.headless;

  security.sudo.extraConfig = let
    sudoLecture = pkgs.writeText "sudo-lecture.txt" (extendedLib.termColors.front.red "Be careful or something, idk...\n");
  in ''
    Defaults    lecture = always
    Defaults    lecture_file = ${sudoLecture}
  '';

  system.stateVersion = "22.05";
}
