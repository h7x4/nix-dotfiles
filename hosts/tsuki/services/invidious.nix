{ config, ... }:
{
  sops.secrets."postgres/invidious" = {
    restartUnits = [ "invidious.service" ];
  };

  services.invidious = {
    enable = true;
    domain = "yt.nani.wtf";

    port = 19283;

    database = {
      createLocally = true;
      passwordFile = config.sops.secrets."postgres/invidious".path;
    };

    settings = {
      registration_enabled = false;

      # popular_enabled = false;
    };
  };
}

