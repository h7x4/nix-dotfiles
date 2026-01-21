{ config, lib, fp, ... }:
let
  synapseConfig = config.services.matrix-synapse-next;
  matrixDomain = "matrix.nani.wtf";
  cfg = config.services.livekit;
in
{
  sops.secrets."matrix/livekit/keyfile/lk-jwt-service" = { };
  sops.templates."matrix-livekit-keyfile" = {
    restartUnits = [
      "livekit.service"
      "lk-jwt-service.service"
    ];
    content = ''
      lk-jwt-service: ${config.sops.placeholder."matrix/livekit/keyfile/lk-jwt-service"}
    '';
  };

  services.matrix-well-known.client = lib.mkIf cfg.enable {
    "org.matrix.msc4143.rtc_foci" = [{
      type = "livekit";
      livekit_service_url = "https://${matrixDomain}/livekit/jwt";
    }];
  };

  services.livekit = {
    enable = true;
    openFirewall = true;
    keyFile = config.sops.templates."matrix-livekit-keyfile".path;

    # NOTE: needed for ingress/egress workers
    # redis.createLocally = true;

    # settings.room.auto_create = false;
  };

  services.lk-jwt-service = lib.mkIf cfg.enable {
    enable = true;
    livekitUrl = "wss://${matrixDomain}/livekit/sfu";
    keyFile = config.sops.templates."matrix-livekit-keyfile".path;
  };

  systemd.services.lk-jwt-service.environment.LIVEKIT_FULL_ACCESS_HOMESERVERS = lib.mkIf cfg.enable matrixDomain;

  services.nginx.virtualHosts.${matrixDomain} = lib.mkIf cfg.enable {
    locations."^~ /livekit/jwt/" = {
      proxyPass = "http://localhost:${toString config.services.lk-jwt-service.port}/";
    };

    # TODO: load balance to multiple livekit ingress/egress workers
    locations."^~ /livekit/sfu/" = {
      proxyPass = "http://localhost:${toString config.services.livekit.settings.port}/";
      proxyWebsockets = true;
      extraConfig = ''
        proxy_send_timeout 120;
        proxy_read_timeout 120;
        proxy_buffering off;
        proxy_set_header Accept-Encoding gzip;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
      '';
    };
  };
}
