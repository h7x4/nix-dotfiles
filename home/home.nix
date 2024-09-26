{ config, pkgs, lib, extendedLib, inputs, machineVars, ... } @ args: let
  inherit (lib) mkForce mkIf optionals;
  graphics = !machineVars.headless;
in {
  imports = [
    ./shell.nix
    ./packages.nix

    ./config/xdg

    ./programs/aria2.nix
    ./programs/atuin.nix
    ./programs/beets.nix
    ./programs/comma.nix
    ./programs/direnv
    ./programs/gdb.nix
    ./programs/gh.nix
    ./programs/gh-dash.nix
    ./programs/git
    ./programs/gpg
    ./programs/jq.nix
    ./programs/less.nix
    ./programs/neovim
    ./programs/nix-index
    ./programs/ssh
    ./programs/tealdeer
    ./programs/thunderbird.nix
    ./programs/tmux.nix
    ./programs/zsh

    ./services/nix-channel-update.nix
    ./services/pueue.nix

    ./modules/colors.nix
    ./modules/shellAliases.nix
  ] ++ optionals graphics [
    ./config/gtk.nix

    ./programs/alacritty.nix
    ./programs/emacs
    ./programs/firefox.nix
    ./programs/ncmpcpp.nix
    ./programs/newsboat
    ./programs/qutebrowser.nix
    ./programs/rofi.nix
    ./programs/taskwarrior.nix
    ./programs/vscode
    # ./programs/xmobar
    ./programs/xmonad
    ./programs/zathura.nix
    ./programs/zed

    ./services/copyq.nix
    ./services/dunst.nix
    ./services/fcitx5.nix
    ./services/mpd.nix
    ./services/picom.nix
    ./services/polybar.nix
    ./services/screen-locker.nix
    # ./services/stalonetray.nix
    ./services/sxhkd.nix
    ./services/tumblerd.nix
  ];

  sops.defaultSopsFile = ../secrets/home.yaml;
  sops.age.sshKeyPaths = [ "${config.home.homeDirectory}/.ssh/id_ed25519_home_sops" ];

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
      _JAVA_AWT_WM_NONREPARENTING = "1";
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
      bashrcExtra = ''
        source "${config.xdg.configHome}/mutable_env.sh"
      '';
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
