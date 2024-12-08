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
    ./programs/bash.nix
    ./programs/bat.nix
    ./programs/beets.nix
    ./programs/bottom.nix
    ./programs/comma.nix
    ./programs/direnv
    ./programs/eza.nix
    ./programs/fzf.nix
    ./programs/gdb.nix
    ./programs/gh-dash.nix
    ./programs/gh.nix
    ./programs/git
    ./programs/gpg
    ./programs/home-manager.nix
    ./programs/jq.nix
    ./programs/less.nix
    ./programs/man.nix
    ./programs/neovim
    ./programs/nix-index
    ./programs/pandoc.nix
    ./programs/ripgrep.nix
    ./programs/ssh
    ./programs/tealdeer
    ./programs/texlive.nix
    ./programs/thunderbird.nix
    ./programs/tmux
    ./programs/yt-dlp.nix
    ./programs/zoxide.nix
    ./programs/zsh

    ./services/nix-channel-update.nix
    ./services/pueue.nix

    ./modules/colors.nix
    ./modules/shellAliases.nix
    ./modules/uidGid.nix
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
    ./programs/qutebrowser.nix
    ./programs/rofi.nix
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
    ./services/network-manager.nix
    ./services/psd.nix
    ./services/tumblerd.nix
  ]) ++ (optionals machineVars.wayland [
    ./programs/hyprland.nix
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
