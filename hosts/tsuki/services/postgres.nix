{ config, pkgs, lib, secrets, ... }: {

  services.postgresql = {
    enable = true;
    enableTCPIP = true;
    authentication = pkgs.lib.mkOverride 10 ''
      local all all trust
      local hydra all ident map=hydra-users
      host all all 127.0.0.1/32 trust
      host all all ::1/128 trust
    '';
    port = secrets.ports.postgres;
    dataDir = "${config.machineVars.dataDrives.drives.postgres}/${config.services.postgresql.package.psqlSchema}";
    # settings = {};
  };

  sops.secrets = {
    "pgadmin/oauth2_secret" = rec {
      restartUnits = [ "pgadmin.service" ];
      owner = config.systemd.services.pgadmin.serviceConfig.User;
      group = config.users.users.${owner}.group;
    };
    "pgadmin/initialPassword" = rec {
      restartUnits = [ "pgadmin.service" ];
      owner = config.systemd.services.pgadmin.serviceConfig.User;
      group = config.users.users.${owner}.group;
    };
  };

  services.pgadmin = {
    enable = true;
    openFirewall = true;
    initialEmail = "h7x4@nani.wtf";
    initialPasswordFile = config.sops.secrets."pgadmin/initialPassword".path;
    port = secrets.ports.pgadmin;
    settings = let
      authServerUrl = config.services.kanidm.serverSettings.origin;
    in {
      # FIXME: pgadmin does not work with NFS by default, because it uses
      #        some kind of metafiles in its data directory.
      # DATA_DIR = "${config.machineVars.dataDrives.default}/var/pgadmin";
      DATA_DIR = "/var/lib/pgadmin";
      AUTHENTICATION_SOURCES = [ "oauth2" ];
      OAUTH2_AUTO_CREATE_USER = true;
      OAUTH2_CONFIG = [ rec {
        OAUTH2_NAME = "KaniDM";
        OAUTH2_DISPLAY_NAME = "KaniDM";
        OAUTH2_CLIENT_ID = "pgadmin";
        OAUTH2_API_BASE_URL = "${authServerUrl}/oauth2";
        OAUTH2_TOKEN_URL = "${authServerUrl}/oauth2/token";
        OAUTH2_AUTHORIZATION_URL = "${authServerUrl}/ui/oauth2";
        OAUTH2_USERINFO_ENDPOINT = "${authServerUrl}/oauth2/openid/${OAUTH2_CLIENT_ID}/userinfo";
        OAUTH2_SERVER_METADATA_URL = "${authServerUrl}/oauth2/openid/${OAUTH2_CLIENT_ID}/.well-known/openid-configuration";
        OAUTH2_SCOPE = "openid email profile";
        OAUTH2_ICON = "fa-lock";
        OAUTH2_BUTTON_COLOR = "#ff6600";
      }];
    };
  };

  environment.etc."pgadmin/config_system.py".text = let
  in ''
    with open("${config.sops.secrets."pgadmin/oauth2_secret".path}") as f:
      OAUTH2_CONFIG[0]['OAUTH2_CLIENT_SECRET'] = f.read()
  '';

  services.postgresqlBackup = {
    enable = true;
    location = "${config.machineVars.dataDrives.drives.backup}/postgres";
    backupAll = true;
  };

  environment.systemPackages = [ config.services.postgresql.package ];
}
