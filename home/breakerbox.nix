{ config, lib, machineVars, ... }:
let
  inherit (lib) mkForce mkIf optionals;
  graphics = !machineVars.headless;
in
{
  imports = [
    ./programs/nix.nix

    ./programs/aria2.nix
    ./programs/atuin.nix
    ./programs/bash.nix
    ./programs/bat.nix
    ./programs/beets.nix
    ./programs/bottom.nix
    ./programs/cargo.nix
    # ./programs/comma.nix
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
  programs.git.enable = true;
  programs.gpg.enable = true;
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
  programs.texlive.enable = true;
  programs.tmux.enable = true;
  programs.uv.enable = true;
  programs.yazi.enable = true;
  programs.yt-dlp.enable = true;
  programs.zoxide.enable = true;
  programs.zsh.enable = true;

  services.pueue.enable = true;

  programs.thunderbird.enable = graphics;
}
