{ config, pkgs, lib, ... }:
let
  cfg = config.services.displayManager;
in
{
  services.displayManager = lib.mkIf (!config.machineVars.headless) {
    enable = true;
    defaultSession = if config.machineVars.wayland
                       then "hyprland-uwsm"
                       else "none+xmonad";
    sddm = {
      enable = true;
      wayland.enable = config.machineVars.wayland;
      package = pkgs.kdePackages.sddm;
      theme = "sddm-astronaut-theme";
      extraPackages = with pkgs.kdePackages; [
        qt5compat
        qtmultimedia
        # pkgs.sddm-astronaut
      ];
    };
  };

  environment.systemPackages = lib.mkIf (cfg.enable && cfg.sddm.enable) [
    (pkgs.sddm-astronaut.override {
      themeConfig = {
        PartialBlur = false;
        # Background = "Backgrounds/";
      };
    })
  ];
}
