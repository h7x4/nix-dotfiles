{ pkgs, unstable-pkgs, lib, extendedLib, config, inputs, secrets, ... }:
let
  # inherit (specialArgs) machineVars;
  inherit (config) machineVars;
  # has_graphics = !config.machineVars.headless;
in {
  nixpkgs.config = {
    allowUnfree = true;
  };

  nix = {
    package = unstable-pkgs.nixVersions.stable;
    distributedBuilds = config.networking.hostName != "Tsuki";

    extraOptions = ''
      experimental-features = nix-command flakes
      builders-use-substitutes = true
      allowed-uris = http:// https://
    '';

    settings = {
      trusted-users = [ "h7x4" "nix-builder" ];
      binary-caches = [
        "https://cache.nixos.org/"
      ];
    };

    buildMachines = [
      {
        # Login details configured in ssh module in nix-secrets
        hostName = "nix-builder-tsukir";
        system = "x86_64-linux";
        speedFactor = 5;
        maxJobs = 8;
        supportedFeatures = [
          "nixos-test"
          "benchmark"
          "big-paralell"
        ];
        mandatoryFeatures = [];
        sshUser = "nix-builder";
        sshKey = secrets.keys.ssh.nixBuilders.tsuki.private;
      }
      {
        # Login details configured in ssh module in nix-secrets
        hostName = "nix-builder-isvegg";
        system = "x86_64-linux";
        speedFactor = 7;
        maxJobs = 16;
        supportedFeatures = [
          "benchmark"
          "big-paralell"
        ];
        mandatoryFeatures = [];
        sshUser = secrets.ssh.users.pvv.normalUser;
        sshKey = secrets.keys.ssh.nixBuilders.isvegg.private;
      }
    ];
    # registry = {

    # };
  };

  programs.ssh = {
    extraConfig = ''
      Host nix-builder-isvegg
        HostName isvegg.pvv.ntnu.no

      Host nix-builder-tsukir
        HostName gingakei.loginto.me
        Port ${toString secrets.ports.ssh.home-in}
    '';
    knownHosts = {
      tsukir = {
        hostNames = [ "nani.wtf" "gingakei.loginto.me" ];
        publicKeyFile = secrets.keys.ssh.nixBuilders.tsuki.public;
      };
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
      # TODO: move this out of etc, and reference it directly in sudo config.
      sudoLecture = {
        target = "sudo.lecture";
        text = extendedLib.termColors.front.red "Be careful or something, idk...\n";
      };

      "resolv.conf".source = let
        inherit (lib.strings) concatStringsSep;
        inherit (pkgs) writeText;
      in writeText "resolv.conf" ''
        ${concatStringsSep "\n" (map (ns: "nameserver ${ns}") config.networking.nameservers)}
        options edns0
      '';

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
        "wheel"
        "networkmanager"
        "docker"
        "disk"
        "audio"
        "video"
        "libvirtd"
        "input"
      ];
    };

    groups = {
      adbusers.members = [ "h7x4" ];
    };
  };

  services = {
    tumbler.enable = !config.machineVars.headless;
    gnome.gnome-keyring.enable = !config.machineVars.headless;

    openssh = {
      # enable = true;
      passwordAuthentication = false;
      kbdInteractiveAuthentication = false;
      permitRootLogin = "no";
    };

    udev.packages = with pkgs; [
      yubikey-personalization
      android-udev-rules
    ];

    pcscd.enable = true;

    dbus = {
      # enable = !machineVars.headless;
      packages = with pkgs; [
        gcr
        dconf
      ];
    };

    xserver = {
      # TODO: What is going on here?
      #       For some reason, this leads to infinite recursion.
      #       This needs to be fixed!
      #       Same with `displayManager.lightdm.enable`
      #       options are defined in each hosts config file for the time being.
      #
      #       I have a hypothesis that there are some asserts within xserver that
      #       makes it so that other software can not be activated at the same time
      #       and that those asserts triggers some kind of evaluation chain that
      #       recurses infinitely.
      # enable = true;
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

      # displayManager.startx.enable = true;
      # displayManager.gdm.enable = true;
      # displayManager.lightdm.enable = true;
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

    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };

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
      dotnet-sdk_3
      dotnet-sdk_5
      dotnetPackages.Nuget
      elm2nix
      elmPackages.elm
      flutter
      gcc
      ghc
      ghcid
      haskellPackages.Cabal_3_6_3_0
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

  security.sudo.extraConfig = ''
    Defaults    lecture = always
    Defaults    lecture_file = /etc/${config.environment.etc.sudoLecture.target}
  '';

  system.stateVersion = "22.05";
}
