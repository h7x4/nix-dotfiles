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
    servers."ws-tsuki" = {
      listen = {
        host = "127.0.0.1";
        port = 8789;
      };
      enableHTTPS = false;
      environmentFile = config.sops.secrets."wstunnel/http-upgrade-path-prefix-envvars".path;
    };
  };
}
