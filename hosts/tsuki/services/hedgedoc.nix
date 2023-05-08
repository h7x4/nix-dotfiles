{ pkgs, lib, config, options, ... }:
{
  config = {
    # Contains CMD_SESSION_SECRET and CMD_OAUTH2_CLIENT_SECRET
    sops.secrets."hedgedoc/env" = {
      restartUnits = [ "hedgedoc.service" ];
    };

    services.hedgedoc = {
      enable = true;
      workDir = "${config.machineVars.dataDrives.default}/var/hedgedoc";
      environmentFile = config.sops.secrets."hedgedoc/env".path;
      settings = {
        domain = "docs.nani.wtf";
        dbURL = "postgres://hedgedoc:@localhost/hedgedoc";
        email = false;
        allowAnonymous = false;
        allowAnonymousEdits = true;
        protocolUseSSL = true;

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
  };
}
