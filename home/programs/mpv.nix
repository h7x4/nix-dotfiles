{ config, lib, machineVars, ... }:
{
  programs.mpv = {
    enable = !machineVars.headless;

    config = {
      screenshot-directory = "${config.xdg.userDirs.pictures}/mpv-screenshots";

      #https://wiki.nixos.org/wiki/Accelerated_Video_Playback
      hwdec       = "auto-safe";
      vo          = "gpu";
      profile     = "gpu-hq";
      gpu-context = lib.mkIf machineVars.wayland "wayland";
    };
  };
}
