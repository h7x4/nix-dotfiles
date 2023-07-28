{ config, pkgs, ... }: let
  cfg = config.services.navidrome;
in {
  services.navidrome = {
    enable = true;
    settings = {
      Address = "127.0.0.1";
      Port = 4533;
      MusicFolder = "/data2/media/music";
      Prometheus.Enabled = true;
    };
  };

  local.socketActivation.navidrome = {
    enable = true;
    originalSocketAddress = "${cfg.settings.Address}:${toString cfg.settings.Port}";
    newSocketAddress = "/run/navidrome.sock";
    privateNamespace = false;
  };
}
