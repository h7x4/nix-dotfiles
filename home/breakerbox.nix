{ config, lib, machineVars, ... }:
let
  inherit (lib) mkForce mkIf optionals;
  graphics = !machineVars.headless;
in
{
  imports = [
    ./programs/nix.nix

    ./programs/alacritty.nix
    ./programs/anyrun
    ./programs/aria2.nix
    ./programs/atuin.nix
    ./programs/bash.nix
    ./programs/bat.nix
    ./programs/beets.nix
    ./programs/bottom.nix
    ./programs/cargo.nix
    # ./programs/comma.nix
    ./programs/direnv
    ./programs/emacs
    ./programs/eza.nix
    ./programs/feh.nix
    ./programs/firefox.nix
    ./programs/fzf.nix
    ./programs/gdb.nix
    ./programs/gh-dash.nix
    ./programs/gh.nix
    ./programs/ghci.nix
    ./programs/git
    ./programs/gpg.nix
    ./programs/home-manager.nix
    ./programs/hyprland
    ./programs/jq.nix
    ./programs/less.nix
    ./programs/man.nix
    ./programs/mpv.nix
    ./programs/ncmpcpp.nix
    ./programs/neovim
    ./programs/newsboat
    ./programs/nix-index
    ./programs/nushell.nix
    ./programs/obs-studio.nix
    ./programs/pandoc.nix
    ./programs/prism-launcher.nix
    ./programs/python.nix
    ./programs/qutebrowser.nix
    ./programs/ripgrep.nix
    ./programs/rofi
    ./programs/skim.nix
    ./programs/sqlite.nix
    ./programs/ssh
    ./programs/taskwarrior.nix
    ./programs/tealdeer
    ./programs/texlive.nix
    ./programs/thunderbird.nix
    ./programs/tmux
    ./programs/uv.nix
    ./programs/vscode
    ./programs/waybar.nix
    ./programs/yazi.nix
    ./programs/yt-dlp.nix
    ./programs/zathura.nix
    ./programs/zed
    ./programs/zoxide.nix
    ./programs/zsh

    ./services/copyq.nix
    ./services/dunst.nix
    ./services/gnome-keyring.nix
    ./services/mpd.nix
    ./services/mpris-proxy.nix
    ./services/network-manager.nix
    ./services/nix-channel-update.nix
    ./services/psd.nix
    ./services/pueue.nix
    ./services/tumblerd.nix
  ] ++ (optionals graphics [
    ./config/gtk.nix


    ./services/fcitx5.nix
    ./services/keybase.nix
  ]) ++ (optionals (!machineVars.wayland) [
    ./programs/xmonad
    # ./programs/xmobar

    ./services/picom.nix
    ./services/polybar.nix
    ./services/screen-locker.nix
    # ./services/stalonetray.nix
    ./services/sxhkd.nix
  ]);

  programs.aria2.enable = true;
  programs.atuin.enable = true;
  programs.bash.enable = true;
  programs.bat.enable = true;
  programs.beets.enable = true;
  programs.bottom.enable = true;
  programs.cargo.enable = true;
  # programs.comma.enable = true;
  programs.direnv.enable = true;
  programs.eza.enable = true;
  programs.fzf.enable = true;
  programs.gdb.enable = true;
  programs.gh-dash.enable = true;
  programs.gh.enable = true;
  programs.ghci.enable = true;
  programs.git.enable = true;
  programs.gpg.enable = true;
  programs.helix.enable = true;
  programs.home-manager.enable = true;
  programs.jq.enable = true;
  programs.less.enable = true;
  programs.man.enable = true;
  programs.neovim.enable = true;
  programs.nix-index.enable = true;
  programs.nushell.enable = true;
  programs.pandoc.enable = true;
  programs.python.enable = true;
  programs.ripgrep.enable = true;
  programs.skim.enable = true;
  programs.sqlite.enable = true;
  programs.ssh.enable = true;
  programs.tealdeer.enable = true;
  programs.tmux.enable = true;
  programs.uv.enable = true;
  programs.yazi.enable = true;
  programs.yt-dlp.enable = true;
  programs.zoxide.enable = true;
  programs.zsh.enable = true;

  services.pueue.enable = true;

  programs.alacritty.enable = graphics;
  programs.emacs.enable = graphics;
  programs.feh.enable = graphics;
  programs.firefox.enable = graphics;
  programs.mpv.enable = graphics;
  programs.ncmpcpp.enable = graphics;
  programs.newsboat.enable = graphics;
  programs.obs-studio.enable = graphics;
  programs.prism-launcher.enable = graphics;
  programs.qutebrowser.enable = graphics;
  programs.rofi.enable = graphics;
  programs.taskwarrior.enable = graphics;
  programs.texlive.enable = graphics;
  programs.thunderbird.enable = graphics;
  programs.vscode.enable = graphics;
  programs.zathura.enable = graphics;
  programs.zed-editor.enable = graphics;

  services.copyq.enable = graphics;
  services.dunst.enable = graphics;
  services.gnome-keyring.enable = graphics;
  services.mpd.enable = graphics;
  services.mpris-proxy.enable = graphics;
  services.network-manager-applet.enable = graphics;
  services.psd.enable = graphics;
  services.tumblerd.enable = graphics;

  programs.anyrun.enable = machineVars.wayland;
  programs.waybar.enable = machineVars.wayland;
  wayland.windowManager.hyprland.enable = machineVars.wayland;
}
