{ config, pkgs, lib, extendedLib, inputs, machineVars, hostname, ... } @ args: let
  inherit (lib) mkForce mkIf optionals;
  graphics = !machineVars.headless;
in {
  imports = [
    ./shell.nix
    ./packages.nix

    ./config/ssh
    ./config/xdg

    ./programs/atuin.nix
    ./programs/comma.nix
    ./programs/direnv.nix
    ./programs/gdb.nix
    ./programs/gh.nix
    ./programs/git.nix
    ./programs/gpg.nix
    ./programs/less.nix
    ./programs/neovim.nix
    ./programs/tmux.nix
    ./programs/zsh

    ./services/git-maintenance.nix

    ./modules/colors.nix
    ./modules/shellAliases.nix
  ] ++ optionals graphics [
    ./config/gtk.nix

    ./programs/alacritty.nix
    ./programs/emacs
    ./programs/firefox.nix
    ./programs/ncmpcpp.nix
    ./programs/ncmpcpp.nix
    ./programs/newsboat
    ./programs/qutebrowser.nix
    ./programs/rofi.nix
    ./programs/taskwarrior.nix
    ./programs/vscode.nix
    # ./programs/xmobar
    ./programs/xmonad
    ./programs/zathura.nix

    ./services/dunst.nix
    ./services/fcitx5.nix
    ./services/mpd.nix
    ./services/picom.nix
    ./services/polybar.nix
    ./services/screen-locker.nix
    # ./services/stalonetray.nix
    ./services/sxhkd.nix
    ./services/copyq.nix
  ];

  sops.defaultSopsFile = ./secrets/${hostname}.yaml;
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

  sops.secrets."nix/access-tokens" = {
    sopsFile = ../secrets/common.yaml;
  };

  nix = {
    settings.use-xdg-base-directories = true;
    extraOptions = ''
      !include ${config.sops.secrets."nix/access-tokens".path}
    '';
  };

  home = {
    username = "h7x4";
    homeDirectory = "/home/h7x4";

    sessionPath = [
      "$HOME/.local/bin"
    ];

    # TODO: fix overriding home.file in home-manager
    # file = mkIf graphics {
    #   ".icons/default/index.theme".source = lib.mkForce null;
    #   ".icons/default/${config.home.pointerCursor.name}.theme".source = lib.mkForce null;
    # };

    pointerCursor = mkIf graphics  {
      package = pkgs.capitaine-cursors;
      name = "capitaine-cursors";
      size = 16;
    };

    keyboard.options = [ "caps:escape" ];

    sessionVariables = {
      CARGO_NET_GIT_FETCH_WITH_CLI = "true";
      PYTHONSTARTUP = "${config.xdg.configHome}/python/pyrc";
    };
  };

  xdg.configFile = {
    "ghc/ghci.conf".text = ''
      :set prompt "${extendedLib.termColors.front.magenta "[GHCi]λ"} "
    '';

    "python/pyrc".text = ''
      #!/usr/bin/env python3
      import sys

      # You also need \x01 and \x02 to separate escape sequence, due to:
      # https://stackoverflow.com/a/9468954/1147688
      sys.ps1='\x01\x1b${extendedLib.termColors.front.blue "[Python]> "}\x02>>>\x01\x1b[0m\x02 '  # bright yellow
      sys.ps2='\x01\x1b[1;49;31m\x02...\x01\x1b[0m\x02 '  # bright red
    '';
  };

  news.display = "silent";

  fonts.fontconfig.enable = mkForce true;

  programs = {
    home-manager.enable = true;

    bash = {
      enable = true;
      historyFile = "${config.xdg.dataHome}/bash_history";
      historySize = 100000;
    };

    bat.enable = true;
    bottom = {
      enable = true;
      settings.flags.enable_gpu = true;
    };
    eza.enable = true;
    feh.enable = mkIf graphics true;
    fzf = {
      enable = true;
      defaultCommand = "fd --type f";
    };
    man = {
      enable = true;
      generateCaches = true;
    };
    mpv.enable = mkIf graphics true;
    obs-studio.enable = mkIf graphics true;
    ssh = {
      enable = true;
      includes = [ "mutable_config" ];
    };
    texlive = {
      enable = true;
      # packageSet = pkgs.texlive.combined.scheme-medium;
    };
    tealdeer = {
      enable = true;
      settings.updates.auto_update = true;
    };
    zoxide.enable = true;
  };

  services = {
    gnome-keyring.enable = mkIf graphics true;
    network-manager-applet.enable = mkIf graphics true;
  };

  manual = {
    html.enable = true;
    manpages.enable = true;
    json.enable = true;
  };

  qt = mkIf graphics {
    enable = true;
    platformTheme.name = "gtk";
    style = {
      name = "adwaita-dark";
      package = pkgs.adwaita-qt;
    };
  };
}
