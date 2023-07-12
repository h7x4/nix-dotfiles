{ pkgs, lib, config, options, ... }: let
  cfg = config.services.hedgedoc;
in {
  imports = [ ./hedgedoc.nix  ];
  disabledModules = [ "services/web-apps/hedgedoc.nix" ];

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
        email = false;
        allowAnonymous = false;
        allowAnonymousEdits = true;
        protocolUseSSL = true;

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

    systemd.services.hedgedoc = {
      requires = [
        "postgresql.service"
        "kanidm.service"
      ];
      serviceConfig = {
        CapabilityBoundingSet = "";
        LockPersonality = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateMounts = true;
        PrivateTmp = true;
        PrivateUsers = true;
        ProtectClock = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";
        ProtectSystem = "strict";
        ReadWritePaths = [ cfg.workDir ];
        RemoveIPC = true;
        RestrictSUIDSGID = true;
        UMask = "0007";
        RestrictAddressFamilies = [ "AF_UNIX AF_INET AF_INET6" ];
        SystemCallArchitectures = "native";
        SystemCallFilter = "~@clock @cpu-emulation @debug @keyring @module @mount @obsolete @raw-io @reboot @setuid @swap";
      };
    };
  };
}
