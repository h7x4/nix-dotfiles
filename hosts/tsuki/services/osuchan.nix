{ config, ... }:
{
  sops.secrets."osuchan/envfile" = {
    restartUnits = [ "osuchan.service" ];
  };

  services.osuchan = {
    enable = true;
    port = 9283;
    secretFile = config.sops.secrets."osuchan/envfile".path;
  };
}
