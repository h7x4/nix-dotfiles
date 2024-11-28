{ config, ... }:
{
  sops = {
    secrets = {
      "osuchan/env/channel_access_token" = { };
      "osuchan/env/channel_id" = { };
      "osuchan/env/channel_secret" = { };
    };
    templates."osuchan.env" = {
      restartUnits = [ "osuchan.service" ];
      content = let
        inherit (config.sops) placeholder;
      in ''
        CHANNEL_ACCESS_TOKEN=${placeholder."osuchan/env/channel_access_token"}
        CHANNEL_ID=${placeholder."osuchan/env/channel_id"}
        CHANNEL_SECRET=${placeholder."osuchan/env/channel_secret"}
      '';
    };
  };

  services.osuchan = {
    enable = true;
    port = 9283;
    secretFile = config.sops.templates."osuchan.env".path;
  };
}
