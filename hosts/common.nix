{ pkgs, config, inputs, specialArgs, ... }:
let
  inherit (pkgs) lib;
  inherit (specialArgs) machineVars;
in {
  nixpkgs.config = {
    allowUnfree = true;
  };


  nix = {
    package = pkgs.nixFlakes;
    distributedBuilds = machineVars.hostname != "Tsuki";
    binaryCaches = [
      "https://cache.nixos.org/"
    ];

    extraOptions = ''
      experimental-features = nix-command flakes
	    builders-use-substitutes = true
    '';

    trustedUsers = [ "h7x4" ];

    buildMachines = [
      {
        hostName = "Tsuki";
        system = "x86_64-linux";
        maxJobs = 1;
        speedFactor = 3;
        supportedFeatures = [
          "nixos-test"
          "benchmark"
          "big-paralell"
          "kvm"
        ];
        mandatoryFeatures = [];
      }
    ];
    # registry = {

    # };
  };

  time.timeZone = "Europe/Oslo";

  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  i18n = {
    defaultLocale = "en_US.UTF-8";
    inputMethod = lib.mkIf (!machineVars.headless) {
      enabled = "fcitx";
      fcitx.engines = with pkgs.fcitx-engines; [ mozc ];
    };

    # inputMethod = {
    #   enabled = "fcitx5";
    #   fcitx5.addons = with pkgs; [
    #     fcitx5-mozc
    #     fcitx5-gtk
    #   ];
    # };
  };

  networking = {
    nameservers = [
      "1.1.1.1"
      "8.8.8.8"
    ];
  };

  environment = {
    variables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };

    shells = with pkgs; [
      bashInteractive
      zsh
      dash
    ];

    systemPackages = with pkgs; [
      wget 
    ] ++ (lib.optionals (!machineVars.headless) [
      haskellPackages.xmobar
    ]);

    etc = {
      # TODO: move this out of etc, and reference it directly in sudo config.
      sudoLecture = {
        target = "sudo.lecture";
        text = lib.termColors.front.red "Be careful or something, idk...\n";
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
  };

  fonts = {
    enableDefaultFonts = true;

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

  home-manager = {
    useGlobalPkgs = true;
    extraSpecialArgs = specialArgs;

    # TODO: figure out why specialArgs isn't accessible from the root home file.
    users.h7x4 = import ../home.nix {
      inherit pkgs;
      inherit (specialArgs) machineVars inputs;
    };
  };

  services = {
    tumbler.enable = !machineVars.headless;
    gnome.gnome-keyring.enable = !machineVars.headless;

    openssh = {
      # enable = true;
      passwordAuthentication = false;
      kbdInteractiveAuthentication = false;
      permitRootLogin = "no";
    };

    dbus = {
      enable = !machineVars.headless;
      packages = with pkgs; [
        gcr
        dconf
      ];
    };

    xserver = {
      enable = !machineVars.headless;
      layout = "us";
      xkbOptions = "caps:escape";

      libinput = {
        enable = true;
        touchpad.disableWhileTyping = true;
      };

      desktopManager = {
        xterm.enable = false;
        xfce.enable = true;
      };

      windowManager.xmonad = {
        enable = true;
        enableContribAndExtras = true;
      };

      displayManager.defaultSession = "none+xmonad";
    };

  };

  programs = {
    dconf.enable = !machineVars.headless;
    git.enable = true;
    light.enable = !machineVars.headless;
    npm.enable = true;
    tmux.enable = true;

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

  sound = {
    enable = !machineVars.headless;
    mediaKeys.enable = true;
  };

  hardware.pulseaudio.enable = !machineVars.headless;

  security.sudo.extraConfig = ''
    Defaults    lecture = always
    Defaults    lecture_file = /etc/${config.environment.etc.sudoLecture.target}
  '';
 
  system.stateVersion = "22.05";
}
