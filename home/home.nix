{ pkgs, inputs, machineVars, colors, ... } @ args: let
  inherit (pkgs) lib;
  inherit (pkgs.lib) mkForce mkIf optionals;
  graphics = !machineVars.headless;
in {
  inherit machineVars;
  inherit colors;

  imports = [
    ./shellOptions.nix
    ./packages.nix

    ./config/ssh/hosts/pvv.nix
    ./config/xdg

    ./programs/comma.nix
    ./programs/firefox.nix
    ./programs/gh.nix
    ./programs/git.nix
    ./programs/gpg.nix
    ./programs/less.nix
    ./programs/neovim.nix
    ./programs/newsboat.nix
    ./programs/tmux.nix
    ./programs/zsh

    ../modules

    inputs.secrets.outputs.home-config
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
  ];

  home = {
    stateVersion = "22.05";
    username = "h7x4";
    homeDirectory = "/home/h7x4";
    file = {
      ".ghci".text = ''
        :set prompt "${lib.termColors.front.magenta "[GHCi]λ"} ".
      '';

      ".pyrc".text = ''
        #!/usr/bin/env python3
        import sys

        # You also need \x01 and \x02 to separate escape sequence, due to:
        # https://stackoverflow.com/a/9468954/1147688
        sys.ps1='\x01\x1b${lib.termColors.front.blue "[Python]> "}\x02>>>\x01\x1b[0m\x02 '  # bright yellow
        sys.ps2='\x01\x1b[1;49;31m\x02...\x01\x1b[0m\x02 '  # bright red
      '';
    };

    pointerCursor = mkIf graphics  {
      package = pkgs.capitaine-cursors;
      name = "capitaine-cursors";
      size = 16;
    };
  };

  news.display = "silent";

  fonts.fontconfig.enable = mkForce true;

  programs = {
    home-manager.enable = true;

    bat.enable = true;
    bottom.enable = true;
    exa.enable = true;
    feh.enable = mkIf graphics true;
    fzf = {
      enable = true;
      defaultCommand = "fd --type f";
    };
    irssi.enable = true;
    kakoune.enable = true;
    lazygit.enable = true;
    man = {
      enable = true;
      generateCaches = true;
    };
    mpv.enable = mkIf graphics true;
    obs-studio.enable = mkIf graphics true;
    ssh.enable = true;
    skim = {
      enable = true;
      defaultCommand ="fd --type f";
    };
    texlive = {
      enable = true;
      # packageSet = pkgs.texlive.combined.scheme-medium;
    };
    zoxide.enable = true;
  };

  services = {
    gnome-keyring.enable = mkIf graphics true;
    dropbox.enable = true;
    network-manager-applet.enable = mkIf graphics true;
    # redshift.enable = true;
  };

  manual = {
    html.enable = true;
    manpages.enable = true;
    json.enable = true;
  };

  qt = mkIf graphics {
    enable = true;
    platformTheme = "gtk";
    style = {
      name = "adwaita-dark";
      package = pkgs.adwaita-qt;
    };
  };
}
