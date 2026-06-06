{ config, lib, ... }:
{
  programs.tealdeer = {
     enableAutoUpdates = true;
  };

  systemd.user.services = lib.mkIf config.services.tldr-update.enable {
    tldr-update.Service = {
      CPUSchedulingPolicy = "idle";
      IOSchedulingClass = "idle";
    };
  };
}
