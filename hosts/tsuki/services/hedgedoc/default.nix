{ pkgs, lib, config, options, ... }: let
  cfg = config.services.hedgedoc;
in {
  imports = [ ./module.nix  ];
  disabledModules = [ "services/web-apps/hedgedoc.nix" ];

  config = {
    # Contains CMD_SESSION_SECRET and CMD_OAUTH2_CLIENT_SECRET
    sops.secrets."hedgedoc/env" = {
      restartUnits = [ "hedgedoc.service" ];
    };

    users.groups.hedgedoc.members = [ "nginx" ];

    services.hedgedoc = {
      enable = true;
      environmentFile = config.sops.secrets."hedgedoc/env".path;
      settings = {
        domain = "docs.nani.wtf";
        email = false;
        allowAnonymous = false;
        allowAnonymousEdits = true;
        protocolUseSSL = true;

        path = "/run/hedgedoc/hedgedoc.sock";

        db = {
          username = "hedgedoc";
          # TODO: set a password
          database = "hedgedoc";
          host = "/var/run/postgresql";
          dialect = "postgresql";
        };

        oauth2 = let
          authServerUrl = config.services.kanidm.serverSettings.origin;
        in rec {
          baseURL = "${authServerUrl}/oauth2";
          tokenURL = "${authServerUrl}/oauth2/token";
          authorizationURL = "${authServerUrl}/ui/oauth2";
          userProfileURL = "${authServerUrl}/oauth2/openid/${clientID}/userinfo";

          clientID = "hedgedoc";

          scope = "openid email profile";
          userProfileUsernameAttr = "name";
          userProfileEmailAttr = "email";
          userProfileDisplayNameAttr = "displayname";

          providerName = "KaniDM";
        };
      };
    };

    services.postgresql = {
      ensureDatabases = [ "hedgedoc" ];
      ensureUsers = [{
        name = "hedgedoc";
        ensurePermissions = {
          "DATABASE \"hedgedoc\"" = "ALL PRIVILEGES";
        };
      }];
    };

    systemd.services.hedgedoc = rec {
      requires = [
        "postgresql.service"
        "kanidm.service"
      ];
      after = requires;
    };
  };
}
