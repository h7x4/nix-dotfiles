{ config, lib, pkgs, inputs, specialArgs, ... }:
{
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

  # security.pam.services.login.unixAuth = true;

  boot.loader = {
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

  networking = {
    hostName = "kasei";
    networkmanager.enable = true;
    useDHCP = false;
    interfaces.wlp5s0.useDHCP = true; 
    interfaces.wlp2s0f0u4.useDHCP = true; 
    nameservers = [
      "1.1.1.1"
      "8.8.8.8"
    ];
    firewall.enable=true;
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

  users.users.h7x4.extraGroups = [
    "wheel"
    "networkmanager"
    "docker"
    "audio"
    "video"
    "disk"
    "libvirtd"
    "input"
  ];

  environment = {
    shellAliases = {
      fixscreen = "xrandr --output DP-4 --mode 1920x1080 --pos 0x0 -r 144 --output DVI-D-1 --primary --mode 1920x1080 --pos 1920x0 -r 60";
    };

    systemPackages = with pkgs; [
      wget
      haskellPackages.xmobar
    ];
  };

  services = {
    openssh = {
      enable = true;
      passwordAuthentication = false;
      challengeResponseAuthentication = false;
      permitRootLogin = "no";
    };
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

      displayManager.lightdm.enable = true;

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
  };

  virtualisation = {
    docker.enable = true;
    libvirtd.enable = true;
  };
}


