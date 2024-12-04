{ config, pkgs, lib, ... }:
{
  services.displayManager = lib.mkIf (!config.machineVars.headless) {
    enable = true;
    defaultSession = "none+xmonad";
    sddm = {
      enable = true;
      # wayland.enable = true;
      package = pkgs.kdePackages.sddm;
      theme = "sddm-astronaut-theme";
      # extraPackages = [ pkgs.sddm-astronaut ];
    };
  };

  environment.systemPackages = [
    (pkgs.sddm-astronaut.override {
      themeConfig = {
        PartialBlur = false;
        # Background = "Backgrounds/";
      };
    })
  ];
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

    # displayManager.lightdm.enable = true;
    # displayManager.defaultSession = "none+xmonad";

    windowManager.xmonad = {
      enable = true;
      enableContribAndExtras = true;
      enableConfiguredRecompile = true;
      extraPackages = hPkgs: with hPkgs; [ dbus ];
    };
  };
}
