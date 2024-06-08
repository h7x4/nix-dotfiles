{ config, pkgs, lib, extendedLib, inputs, machineVars, ... } @ args: let
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
    ./programs/firefox.nix
    ./programs/gdb.nix
    ./programs/gh.nix
    ./programs/git.nix
    ./programs/gpg.nix
    ./programs/less.nix
    ./programs/ncmpcpp.nix
    ./programs/neovim.nix
    ./programs/newsboat
    ./programs/tmux.nix
    ./programs/zsh

    ./modules/colors.nix
    ./modules/shellAliases.nix
  ] ++ optionals graphics [
    ./config/gtk.nix

    ./programs/alacritty.nix
    ./programs/emacs
    ./programs/ncmpcpp.nix
    ./programs/qutebrowser.nix
    ./programs/rofi.nix
    ./programs/vscode.nix
    ./programs/xmobar
    ./programs/xmonad
    ./programs/zathura.nix

    ./services/dunst.nix
    ./services/mpd.nix
    ./services/picom.nix
    ./services/polybar.nix
    ./services/stalonetray.nix
    ./services/sxhkd.nix
    ./services/copyq.nix
  ];

  nix.settings = {
    use-xdg-base-directories = true;
  };

  home = {
    stateVersion = "22.05";
    username = "h7x4";
    homeDirectory = "/home/h7x4";

    sessionPath = [
      "$HOME/.local/bin"
    ];

    pointerCursor = mkIf graphics  {
      package = pkgs.capitaine-cursors;
      name = "capitaine-cursors";
      size = 16;
    };

    keyboard.options = [ "caps:escape" ];

    sessionVariables = {
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
    bottom.enable = true;
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
