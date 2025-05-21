{ config, pkgs, lib, ... }:
{
  services.xserver = lib.mkIf (!config.machineVars.headless) {
    enable = true;

    xkb = {
      layout = "us";
      options = "caps:escape";
    };

    desktopManager = {
      xterm.enable = true;
      xfce.enable = true;
    };

    windowManager.xmonad = {
      enable = true;
      enableContribAndExtras = true;
      enableConfiguredRecompile = true;
      extraPackages = hPkgs: with hPkgs; [ dbus ];
    };
  };

  services.graphical-desktop.enable = !config.machineVars.headless;
  services.speechd.enable = false;
}
