{ config, lib, ... }:
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

    displayManager.lightdm.enable = true;
    displayManager.defaultSession = "none+xmonad";

    windowManager.xmonad = {
      enable = true;
      enableContribAndExtras = true;
      enableConfiguredRecompile = true;
      extraPackages = hPkgs: with hPkgs; [ dbus ];
    };
  };
}
