{ pkgs, ... } @ args:
{
  imports = [
    ./shellOptions.nix
    ./packages.nix

    ./misc/mimetypes.nix
    ./misc/ssh/hosts/pvv.nix

    ./programs/alacritty.nix
    ./programs/comma.nix
    ./programs/emacs.nix
    ./programs/gh.nix
    ./programs/git.nix
    ./programs/ncmpcpp.nix
    ./programs/neovim.nix
    ./programs/newsboat.nix
    ./programs/qutebrowser.nix
    ./programs/rofi.nix
    ./programs/tmux.nix
    ./programs/vscode.nix
    ./programs/xmonad
    ./programs/zathura.nix
    ./programs/zsh

    ./services/dunst.nix
    ./services/mpd.nix
    ./services/picom.nix
    ./services/stalonetray.nix
    ./services/sxhkd.nix
  ];

  home = {
    stateVersion = "21.11";
    username = "h7x4";
    homeDirectory = "/home/h7x4";
  };

  news.display = "silent";

  fonts.fontconfig.enable = true;

  programs = {
    home-manager.enable = true;

    bat.enable = true;
    bottom.enable = true;
    exa.enable = true;
    feh.enable = true;
    fzf = {
      enable = true;
      defaultCommand = "fd --type f";
    };
    gpg.enable = true;
    irssi.enable = true;
    kakoune.enable = true;
    lazygit.enable = true;
    man = {
      enable = true;
      generateCaches = true;
    };
    mpv.enable = true;
    obs-studio.enable = true;
    ssh.enable = true;
    skim = {
      enable = true;
      defaultCommand ="fd --type f";
    };
    texlive = {
      enable = true;
      # packageSet = pkgs.texlive.combined.scheme-medium;
    };
    # xmobar.enable = true;
    zoxide.enable = true;
  };

  services = {
    gnome-keyring.enable = true;
    dropbox.enable = true;
    network-manager-applet.enable = true;
    # redshift.enable = true;
  };

  manual = {
    html.enable = true;
    manpages.enable = true;
    json.enable = true;
  };

  gtk = {
    enable = true;
    font = {
      name = "Droid Sans";
    };
    iconTheme = {
      package = pkgs.papirus-icon-theme;
      name = "Papirus";
    };
    theme = {
      package = pkgs.vimix-gtk-themes;
      name = "VimixDark";
    };
  };

  qt = {
    enable = true;
    platformTheme = "gtk";
    style = {
      name = "adwaita-dark";
      package = pkgs.adwaita-qt;
    };
  };

  xdg.enable = true;

  xsession = {
    pointerCursor = {
      package = pkgs.capitaine-cursors;
      name = "capitaine-cursors";
      size = 16;
    };
  };
}
