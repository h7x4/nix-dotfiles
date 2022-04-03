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

  nix = {
    distributedBuilds = true;
    binaryCaches = [
      "https://cache.nixos.org/"
    ];

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

  users.users.h7x4.extraGroups = [
    "wheel"
    "networkmanager"
    "docker"
    "disk"
    "audio"
    "video"
    "libvirtd"
    "input"
  ];

  environment.systemPackages = with pkgs; [
    wget
    haskellPackages.xmobar
  ];

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

  virtualisation = {
    docker.enable = true;
    libvirtd.enable = true;
  };
}

