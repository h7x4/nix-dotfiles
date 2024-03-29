{ config, ... }: let
  cfg = config.services.invidious;
in {
  sops.secrets."postgres/invidious" = {
    restartUnits = [ "invidious.service" ];
  };

  services.invidious = {
    enable = true;
    domain = "yt.nani.wtf";

    port = 19283;

    # This will implicitly use unix socket
    database = {
      createLocally = true;
      passwordFile = config.sops.secrets."postgres/invidious".path;
    };

    settings = {
      registration_enabled = false;
      host_binding = "127.0.0.1";
      # popular_enabled = false;
    };
  };

  local.socketActivation.invidious = {
    enable = cfg.enable;
    originalSocketAddress = "${cfg.settings.host_binding}:${toString cfg.port}";
    newSocketAddress = "/run/invidious.sock";
    privateNamespace = false;
  };
}

