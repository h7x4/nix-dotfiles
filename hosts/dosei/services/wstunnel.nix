{ config, ... }:
{
  imports = [
    ../../../modules/wstunnel.nix
  ];
  disabledModules = [
    "services/networking/wstunnel.nix"
  ];

  sops = {
    secrets."wstunnel/http-upgrade-path-prefix" = {
      sopsFile = ../../../secrets/common.yaml;
    };
    templates."wstunnel-environment.env".content = let
      inherit (config.sops) placeholder;
    in ''
      WSTUNNEL_HTTP_UPGRADE_PATH_PREFIX=${placeholder."wstunnel/http-upgrade-path-prefix"}
      WSTUNNEL_RESTRICT_HTTP_UPGRADE_PATH_PREFIX=${placeholder."wstunnel/http-upgrade-path-prefix"}
    '';
  };

  services.wstunnel = {
    enable = true;
    clients."ws-tsuki" = {
      connectTo = "wss://ws.nani.wtf";
      localToRemote = [
        "tcp://10022:localhost:22"
      ];
      environmentFile = config.sops.templates."wstunnel-environment.env".path;
    };
  };
}
