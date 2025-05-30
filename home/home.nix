{ config, pkgs, lib, extendedLib, inputs, machineVars, ... } @ args: let
  inherit (lib) mkForce mkIf optionals;
  graphics = !machineVars.headless;
in {
  imports = [
    ./shell.nix
    ./packages.nix

    ./config/xdg
    ./config/ensure-homedir-structure.nix
    ./config/downloads-sorter.nix

    ./programs/aria2.nix
    ./programs/atuin.nix
    ./programs/bash.nix
    ./programs/bat.nix
    ./programs/beets.nix
    ./programs/bottom.nix
    ./programs/cargo.nix
    ./programs/comma.nix
    ./programs/direnv
    ./programs/eza.nix
    ./programs/fzf.nix
    ./programs/gdb.nix
    ./programs/gh-dash.nix
    ./programs/gh.nix
    ./programs/git
    ./programs/gpg.nix
    ./programs/home-manager.nix
    ./programs/jq.nix
    ./programs/less.nix
    ./programs/man.nix
    ./programs/neovim
    ./programs/nix-index
    ./programs/nix.nix
    ./programs/nushell.nix
    ./programs/pandoc.nix
    ./programs/python.nix
    ./programs/ripgrep.nix
    ./programs/skim.nix
    ./programs/sqlite.nix
    ./programs/ssh
    ./programs/tealdeer
    ./programs/texlive.nix
    ./programs/thunderbird.nix
    ./programs/tmux
    ./programs/uv.nix
    ./programs/yazi.nix
    ./programs/yt-dlp.nix
    ./programs/zoxide.nix
    ./programs/zsh

    ./services/nix-channel-update.nix
    ./services/pueue.nix
  ] ++ (optionals graphics [
    ./config/gtk.nix

    ./programs/alacritty.nix
    ./programs/emacs
    ./programs/feh.nix
    ./programs/firefox.nix
    ./programs/mpv.nix
    ./programs/ncmpcpp.nix
    ./programs/newsboat
    ./programs/obs-studio.nix
    ./programs/prism-launcher.nix
    ./programs/qutebrowser.nix
    ./programs/rofi
    ./programs/taskwarrior.nix
    ./programs/vscode
    ./programs/zathura.nix
    ./programs/zed

    ./services/copyq.nix
    ./services/dunst.nix
    ./services/fcitx5.nix
    ./services/gnome-keyring.nix
    ./services/keybase.nix
    ./services/mpd.nix
    ./services/mpris-proxy.nix
    ./services/network-manager.nix
    ./services/psd.nix
    ./services/tumblerd.nix
  ]) ++ (optionals machineVars.wayland [
    ./programs/hyprland
    ./programs/waybar.nix
    ./programs/anyrun
  ]) ++ (optionals (!machineVars.wayland) [
    ./programs/xmonad
    # ./programs/xmobar

    ./services/picom.nix
    ./services/polybar.nix
    ./services/screen-locker.nix
    # ./services/stalonetray.nix
    ./services/sxhkd.nix
  ]);

  sops.defaultSopsFile = ../secrets/home.yaml;
  sops.age.sshKeyPaths = [ "${config.home.homeDirectory}/.ssh/id_ed25519_home_sops" ];

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
      dotIcons.enable = false;
    };

    keyboard.options = [ "caps:escape" ];

    sessionVariables = {
      DO_NOT_TRACK = "1";
      _JAVA_AWT_WM_NONREPARENTING = "1";
    };
  };

  dconf.settings = mkIf graphics {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };

  xsession = {
    enable = !machineVars.wayland;
    # TODO: declare using xdg config home
    scriptPath = ".config/X11/xsession";
    profilePath = ".config/X11/xprofile";
  };

  xdg.configFile = {
    "ghc/ghci.conf".text = ''
      :set prompt "${extendedLib.termColors.front.magenta "[GHCi]λ"} "
    '';
  };

  news.display = "silent";

  fonts.fontconfig.enable = mkForce true;

  manual = {
    html.enable = true;
    manpages.enable = true;
    json.enable = true;
  };

  qt = mkIf graphics {
    enable = true;
    platformTheme.name = "adwaita";
    style.name = "adwaita-dark";
  };
}
