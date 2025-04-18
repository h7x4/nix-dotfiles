{ config, pkgs, lib, ... }:
{
  services.displayManager = lib.mkIf (!config.machineVars.headless) {
    enable = true;
    defaultSession = "none+xmonad";
    sddm = {
      enable = true;
      wayland.enable = config.machineVars.wayland;
      package = pkgs.kdePackages.sddm;
      theme = "sddm-astronaut-theme";
      extraPackages = [
        pkgs.kdePackages.qt5compat
        # pkgs.sddm-astronaut
      ];
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
