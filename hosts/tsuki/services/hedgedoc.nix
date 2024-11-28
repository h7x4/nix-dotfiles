{ pkgs, lib, config, ... }: let
  cfg = config.services.hedgedoc;
in {
  sops = {
    secrets = {
      "hedgedoc/env/cmd_session_secret" = { };
      "hedgedoc/env/cmd_oauth2_client_secret" = { };
    };
    templates."hedgedoc.env" = {
      restartUnits = [ "hedgedoc.service" ];
      owner = "hedgedoc";
      group = "hedgedoc";
      content = let
        inherit (config.sops) placeholder;
      in ''
        CMD_SESSION_SECRET=${placeholder."hedgedoc/env/cmd_session_secret"}
        CMD_OAUTH2_CLIENT_SECRET=${placeholder."hedgedoc/env/cmd_oauth2_client_secret"}
      '';
    };
  };

  users.groups.hedgedoc.members = [ "nginx" ];

  services.hedgedoc = {
    enable = true;
    environmentFile = config.sops.templates."hedgedoc.env".path;
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
        dialect = "postgres";
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
      ensureDBOwnership = true;
    }];
  };

  systemd.services.hedgedoc = rec {
    requires = [
      "postgresql.service"
      "kanidm.service"
    ];
    after = requires;
  };
}
