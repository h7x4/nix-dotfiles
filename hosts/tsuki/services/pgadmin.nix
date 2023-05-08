{ config, pkgs, lib, secrets, ... }: let
  pgadmin-user = let
    username = config.systemd.services.pgadmin.serviceConfig.User;
  in config.users.users.${username};
in {

  sops.secrets = {
    "pgadmin/oauth2_secret" = rec {
      restartUnits = [ "pgadmin.service" ];
      owner = pgadmin-user.name;
      group = pgadmin-user.group;
    };
    "pgadmin/initialPassword" = rec {
      restartUnits = [ "pgadmin.service" ];
      owner = pgadmin-user.name;
      group = pgadmin-user.group;
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

      WTF_CSRF_HEADERS = [
        "X-pgA-CSRFToken"
        "X-CSRFToken"
        "X-CSRF-Token"
      ];

      PROXY_X_FOR_COUNT = 1;
      PROXY_X_PROTO_COUNT = 1;
      PROXY_X_HOST_COUNT = 1;
      PROXY_X_PORT_COUNT = 1;
      PROXY_X_PREFIX_COUNT = 1;

      SESSION_COOKIE_HTTPONLY = false;
      SESSION_COOKIE_SECURE = true;

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

  systemd.services."pgadmin".enable = false;

  users = {
    users."pgadmin".uid = 985;
    groups = {
      "pgadmin" = {
        gid = 984;
        members = [
          "nginx"
          "uwsgi"
        ];
      };
      "uwsgi".members = [ pgadmin-user.name ];
    };
  };

  services.uwsgi = {
    enable = false;
    plugins = [ "python3" ];
    instance = {
      type = "emperor";
      pidfile = "${config.services.uwsgi.runDir}/uwsgi.pid";
      stats = "${config.services.uwsgi.runDir}/stats.sock";
      vassals."pgadmin" = rec {
        type = "normal";
        pythonPackages = _: with pkgs; ([ pgadmin4 ] ++ pgadmin4.propagatedBuildInputs);
        strict = true;
        immediate-uid = pgadmin-user.name;
        immediate-gid = pgadmin-user.group;
        lazy-apps = true;
        enable-threads = true;
        # chdir = "${pkgs.pgadmin4}/lib/python3.10/site-packages/pgadmin4";
        module = "pgAdmin4:app";
        socket = "/run/user/${toString pgadmin-user.uid}/pgadmin.sock";
        chmod-socket = 664;
      };
    };
  };
}
