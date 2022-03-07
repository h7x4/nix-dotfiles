{ pkgs, config, ... }: let
  # FIXME: lib should be imported directly as a module argument.
  inherit (pkgs) lib;

# TODO: Split this file
in {
  imports = [
    ./hardware-configuration.nix
    ../../pluggables/tools/programming.nix
  ];

  systemd.targets = {
    sleep.enable = false;
    suspend.enable = false;
    hibernate.enable = false;
    hybrid-sleep.enable = false;
  };

  boot.loader = {
    efi.canTouchEfiVariables = false;
    grub = {
      enable = true;
      device = "/dev/sda";
      version = 2;
    };
  };

  time.timeZone = "Europe/Oslo";

  networking = {
    hostName = "Eisei";
    networkmanager.enable = true;
    useDHCP = false;

    interfaces = {
      eno1.useDHCP = true;
      wlo1.useDHCP = true;
    };

    # firewall = {
    #   enable = false;
    #   allowedTCPPorts = [ ... ];
    #   allowedUDPPorts = [ ... ];
    # };
  };

  i18n = {
    defaultLocale = "en_US.UTF-8";

    inputMethod = {
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

  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  services = {
    openssh.enable = true;
    gnome.gnome-keyring.enable = true;
    printing.enable = true;
    dbus = {
      enable = true;
      packages = with pkgs; [
        gcr
        gnome3.dconf
      ];
    };
    cron = {
      enable = true;
      systemCronJobs = [
    #     "*/5 * * * *      root    date >> /tmp/cron.log"
      ];
    };

    xserver = {
      enable = true;
      layout = "us";
      xkbOptions = "caps:escape";

      libinput = {
        enable = true;
        touchpad.disableWhileTyping = true;
      };

      windowManager.xmonad = {
        enable = true;
        enableContribAndExtras = true;
      };
    };
  };

  sound.enable = true;
  hardware.pulseaudio.enable = true;

  hardware.bluetooth.enable = true;

  nixpkgs.config = {
    allowUnfree = true;
  };

  nix = {
    distributedBuilds = true;
    package = pkgs.nixFlakes;
    binaryCaches = [
      "https://cache.nixos.org/"
    ];
    extraOptions = ''
      experimental-features = nix-command flakes
	    builders-use-substitutes = true
    '';

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

  };

  users.users.h7x4 = {
    isNormalUser = true;
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
    shell = pkgs.zsh;
  };

  environment = {
    variables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };

    systemPackages = with pkgs; [
      wget
      haskellPackages.xmobar
    ];

    shells = with pkgs; [
      bashInteractive
      zsh
      dash
    ];

    etc = {
      # TODO: move this out of etc, and reference it directly in sudo config.
      sudoLecture = {
        target = "sudo.lecture";
        text = lib.termColors.front.red "Be careful or something, idk...\n";
      };

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
      noto-fonts-cjk
      noto-fonts-emoji
      open-sans
      source-han-sans
      source-sans
      ubuntu_font_family
      victor-mono
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

  programs = {
    dconf.enable = true;
    git.enable = true;
    light.enable = true;
    npm.enable = true;
    tmux.enable = true;
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

    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };

  security.sudo.extraConfig = ''
    Defaults    lecture = always
    Defaults    lecture_file = /etc/${config.environment.etc.sudoLecture.target}
  '';

  virtualisation = {
    docker.enable = true;
    libvirtd.enable = true;
  };

  system.stateVersion = "21.11";
}

