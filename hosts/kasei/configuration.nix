{ config, lib, pkgs, ... }:
{
  imports =
    [
      ./hardware-configuration.nix

      ../../pluggables/tools/programming.nix
    ];

  systemd.targets = {
    sleep.enable = false;
    suspend.enable = false;
    hibernate.enable = false;
    hybrid-sleep.enable = false;
  };

  nix.package = pkgs.nixFlakes;
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  # security.pam.services.login.unixAuth = true;

  boot.loader = {
    grub = {
      enable = true;
      version = 2;
      efiSupport = true;
      fsIdentifier = "label";
      device = "nodev";
      efiInstallAsRemovable = true;
    };
    # efi.efiSysMountPoint = "/boot/efi";
    # efi.canTouchEfiVariables = true;
  };

  time.timeZone = "Europe/Oslo";

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

  # services = {
  #   openssh = {
  #     enable = true;
  #     passwordAuthentication = false;
  #     challengeResponseAuthentication = false;
  #     permitRootLogin = "no";
  #   };
  #   printing.enable = true;
  #   cron = {
  #     enable = true;
  #     systemCronJobs = [
  #   #     "*/5 * * * *      root    date >> /tmp/cron.log"
  #     ];
  #   };
  # };

  users.users = {
    h7x4 = {
      isNormalUser = true;
      extraGroups = [
        "wheel"
        "networkmanager"
        "docker"
        "audio"
        "video"
        "disk"
        "libvirtd"
        "input"
      ];
      shell = pkgs.zsh;
    };
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
      sudoLecture = {
        target = "sudo.lecture";
        text = "[31mBe careful or something, idk...[m\n";
      };

      "resolv.conf" = with lib; with pkgs; {
        source = writeText "resolv.conf" ''
          ${concatStringsSep "\n" (map (ns: "nameserver ${ns}") config.networking.nameservers)}
          options edns0
        '';
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


