{ config, ... }:
{
  imports = [
    ../../../modules/wstunnel.nix
  ];
  disabledModules = [
    "services/networking/wstunnel.nix"
  ];

  # NOTE: Contains
  # - WSTUNNEL_HTTP_UPGRADE_PATH_PREFIX
  # - WSTUNNEL_RESTRICT_HTTP_UPGRADE_PATH_PREFIX
  sops.secrets."wstunnel/http-upgrade-path-prefix-envvars" = {
    sopsFile = ../../../secrets/common.yaml;
  };

  services.wstunnel = {
    enable = true;
    clients."ws-tsuki" = {
      connectTo = "wss://ws.nani.wtf";
      localToRemote = [
        "tcp://10022:localhost:22"
      ];
      environmentFile = config.sops.secrets."wstunnel/http-upgrade-path-prefix-envvars".path;
    };
  };
}
