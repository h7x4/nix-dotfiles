{ config, ... }:
{
  services.xserver = {
    enable = !config.machineVars.headless;

    xkb = {
      layout = "us";
      options = "caps:escape";
    };

    # desktopManager = {
    #   xterm.enable = false;
    #   xfce.enable = !config.machineVars.headless;
    # };

    displayManager.lightdm.enable = !config.machineVars.headless;

    windowManager.xmonad = {
      enable = true;
      enableContribAndExtras = true;
      enableConfiguredRecompile = true;
      extraPackages = hPkgs: with hPkgs; [ dbus ];
    };
  };
}
