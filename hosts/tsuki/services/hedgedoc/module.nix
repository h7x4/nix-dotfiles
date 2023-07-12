{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.hedgedoc;

  # 21.03 will not be an official release - it was instead 21.05.  This
  # versionAtLeast statement remains set to 21.03 for backwards compatibility.
  # See https://github.com/NixOS/nixpkgs/pull/108899 and
  # https://github.com/NixOS/rfcs/blob/master/rfcs/0080-nixos-release-schedule.md.
  name = if versionAtLeast config.system.stateVersion "21.03"
    then "hedgedoc"
    else "codimd";

  settingsFormat = pkgs.formats.json {};

  prettyJSON = conf:
    pkgs.runCommandLocal "hedgedoc-config.json" {
      nativeBuildInputs = [ pkgs.jq ];
    } ''
      jq '{production:del(.[]|nulls)|del(.[][]?|nulls)}' \
        < ${settingsFormat.generate "hedgedoc-ugly.json" cfg.settings} \
        > $out
    '';
in
{
  imports = [
    (mkRenamedOptionModule [ "services" "codimd" ] [ "services" "hedgedoc" ])
    (mkRenamedOptionModule
      [ "services" "hedgedoc" "configuration" ] [ "services" "hedgedoc" "settings" ])
    (mkRenamedOptionModule
      [ "services" "hedgedoc" "groups" ] [ "users" "users" name "extraGroups" ])
    (mkRemovedOptionModule [ "services" "hedgedoc" "workDir" ] ''
      TODO: write paragraph
    '')
  ];

  options.services.hedgedoc = {
    enable = mkEnableOption (lib.mdDoc "the HedgeDoc Markdown Editor");
    enableUnixSocket = mkOption {
      type = types.bool;
      default = false;
      description = lib.mdDoc ''
        Sets up a socket at `/run/hedgedoc/hedgedoc.sock`.

        This socket will be part of the `hedgedoc` group,
        so if you want a webserver like nginx to be able to
        communicate with this socket, you will have to add
        the user of the webserver (nginx in this case) to
        `users.groups.hedgedoc.members`
      '';
    };

    settings = let options = {
      # host = mkOption {
      #   type = types.str;
      #   default = "localhost";
      #   description = lib.mdDoc ''
      #     Address to listen on.
      #   '';
      # };
      # port = mkOption {
      #   type = types.port;
      #   default = 3000;
      #   example = 80;
      #   description = lib.mdDoc ''
      #     Port to listen on.
      #   '';
      # };
      # allowOrigin = mkOption {
      #   type = types.listOf types.str;
      #   default = [];
      #   example = [ "localhost" "hedgedoc.org" ];
      #   description = lib.mdDoc ''
      #     List of domains to whitelist.
      #   '';
      # };
      # useSSL = mkOption {
      #   type = types.bool;
      #   default = false;
      #   description = lib.mdDoc ''
      #     Enable to use SSL server. This will also enable
      #     {option}`protocolUseSSL`.
      #   '';
      # };
      # dbURL = mkOption {
      #   type = types.nullOr types.str;
      #   default = null;
      #   example = ''
      #     postgres://user:pass@host:5432/dbname
      #   '';
      #   description = lib.mdDoc ''
      #     Specify which database to use.
      #     HedgeDoc supports mysql, postgres, sqlite and mssql.
      #     See [
      #     https://sequelize.readthedocs.io/en/v3/](https://sequelize.readthedocs.io/en/v3/) for more information.
      #     Note: This option overrides {option}`db`.
      #   '';
      # };
      # db = mkOption {
      #   type = types.attrs;
      #   default = {};
      #   example = literalExpression ''
      #     {
      #       dialect = "sqlite";
      #       storage = "/var/lib/${name}/db.${name}.sqlite";
      #     }
      #   '';
      #   description = lib.mdDoc ''
      #     Specify the configuration for sequelize.
      #     HedgeDoc supports mysql, postgres, sqlite and mssql.
      #     See [
      #     https://sequelize.readthedocs.io/en/v3/](https://sequelize.readthedocs.io/en/v3/) for more information.
      #     Note: This option overrides {option}`db`.
      #   '';
      # };
      # sslKeyPath= mkOption {
      #   type = types.nullOr types.str;
      #   default = null;
      #   example = "/var/lib/hedgedoc/hedgedoc.key";
      #   description = lib.mdDoc ''
      #     Path to the SSL key. Needed when {option}`useSSL` is enabled.
      #   '';
      # };
      # sslCertPath = mkOption {
      #   type = types.nullOr types.str;
      #   default = null;
      #   example = "/var/lib/hedgedoc/hedgedoc.crt";
      #   description = lib.mdDoc ''
      #     Path to the SSL cert. Needed when {option}`useSSL` is enabled.
      #   '';
      # };
      # sslCAPath = mkOption {
      #   type = types.listOf types.str;
      #   default = [];
      #   example = [ "/var/lib/hedgedoc/ca.crt" ];
      #   description = lib.mdDoc ''
      #     SSL ca chain. Needed when {option}`useSSL` is enabled.
      #   '';
      # };
      # dhParamPath = mkOption {
      #   type = types.nullOr types.str;
      #   default = null;
      #   example = "/var/lib/hedgedoc/dhparam.pem";
      #   description = lib.mdDoc ''
      #     Path to the SSL dh params. Needed when {option}`useSSL` is enabled.
      #   '';
      # };
      # tmpPath = mkOption {
      #   type = types.str;
      #   default = "/tmp";
      #   description = lib.mdDoc ''
      #     Path to the temp directory HedgeDoc should use.
      #     Note that {option}`serviceConfig.PrivateTmp` is enabled for
      #     the HedgeDoc systemd service by default.
      #     (Non-canonical paths are relative to HedgeDoc's base directory)
      #   '';
      # };
      # defaultNotePath = mkOption {
      #   type = types.nullOr types.str;
      #   default = "${cfg.package}/public/default.md";
      #   defaultText = literalExpression "\"\${cfg.package}/public/default.md\"";
      #   description = lib.mdDoc ''
      #     Path to the default Note file.
      #     (Non-canonical paths are relative to HedgeDoc's base directory)
      #   '';
      # };
      # docsPath = mkOption {
      #   type = types.nullOr types.str;
      #   default = "${cfg.package}/public/docs";
      #   defaultText = literalExpression "\"\${cfg.package}/public/docs\"";
      #   description = lib.mdDoc ''
      #     Path to the docs directory.
      #     (Non-canonical paths are relative to HedgeDoc's base directory)
      #   '';
      # };
      # indexPath = mkOption {
      #   type = types.nullOr types.str;
      #   default = "${cfg.package}/public/views/index.ejs";
      #   defaultText = literalExpression "\"\${cfg.package}/public/views/index.ejs\"";
      #   description = lib.mdDoc ''
      #     Path to the index template file.
      #     (Non-canonical paths are relative to HedgeDoc's base directory)
      #   '';
      # };
      # hackmdPath = mkOption {
      #   type = types.nullOr types.str;
      #   default = "${cfg.package}/public/views/hackmd.ejs";
      #   defaultText = literalExpression "\"\${cfg.package}/public/views/hackmd.ejs\"";
      #   description = lib.mdDoc ''
      #     Path to the hackmd template file.
      #     (Non-canonical paths are relative to HedgeDoc's base directory)
      #   '';
      # };
      # errorPath = mkOption {
      #   type = types.nullOr types.str;
      #   default = "${cfg.package}/public/views/error.ejs";
      #   defaultText = literalExpression "\"\${cfg.package}/public/views/error.ejs\"";
      #   description = lib.mdDoc ''
      #     Path to the error template file.
      #     (Non-canonical paths are relative to HedgeDoc's base directory)
      #   '';
      # };
      # prettyPath = mkOption {
      #   type = types.nullOr types.str;
      #   default = "${cfg.package}/public/views/pretty.ejs";
      #   defaultText = literalExpression "\"\${cfg.package}/public/views/pretty.ejs\"";
      #   description = lib.mdDoc ''
      #     Path to the pretty template file.
      #     (Non-canonical paths are relative to HedgeDoc's base directory)
      #   '';
      # };
      # slidePath = mkOption {
      #   type = types.nullOr types.str;
      #   default = "${cfg.package}/public/views/slide.hbs";
      #   defaultText = literalExpression "\"\${cfg.package}/public/views/slide.hbs\"";
      #   description = lib.mdDoc ''
      #     Path to the slide template file.
      #     (Non-canonical paths are relative to HedgeDoc's base directory)
      #   '';
      # };
      # uploadsPath = mkOption {
      #   type = types.str;
      #   default = "${cfg.workDir}/uploads";
      #   defaultText = literalExpression "\"\${cfg.workDir}/uploads\"";
      #   description = lib.mdDoc ''
      #     Path under which uploaded files are saved.
      #   '';
      # };
      # ldap = mkOption {
      #   type = types.nullOr (types.submodule {
      #     options = {
      #       providerName = mkOption {
      #         type = types.str;
      #         default = "";
      #         description = lib.mdDoc ''
      #           Optional name to be displayed at login form, indicating the LDAP provider.
      #         '';
      #       };
      #       url = mkOption {
      #         type = types.str;
      #         example = "ldap://localhost";
      #         description = lib.mdDoc ''
      #           URL of LDAP server.
      #         '';
      #       };
      #       bindDn = mkOption {
      #         type = types.str;
      #         description = lib.mdDoc ''
      #           Bind DN for LDAP access.
      #         '';
      #       };
      #       bindCredentials = mkOption {
      #         type = types.str;
      #         description = lib.mdDoc ''
      #           Bind credentials for LDAP access.
      #         '';
      #       };
      #       searchBase = mkOption {
      #         type = types.str;
      #         example = "o=users,dc=example,dc=com";
      #         description = lib.mdDoc ''
      #           LDAP directory to begin search from.
      #         '';
      #       };
      #       searchFilter = mkOption {
      #         type = types.str;
      #         example = "(uid={{username}})";
      #         description = lib.mdDoc ''
      #           LDAP filter to search with.
      #         '';
      #       };
      #       searchAttributes = mkOption {
      #         type = types.nullOr (types.listOf types.str);
      #         default = null;
      #         example = [ "displayName" "mail" ];
      #         description = lib.mdDoc ''
      #           LDAP attributes to search with.
      #         '';
      #       };
      #       userNameField = mkOption {
      #         type = types.str;
      #         default = "";
      #         description = lib.mdDoc ''
      #           LDAP field which is used as the username on HedgeDoc.
      #           By default {option}`useridField` is used.
      #         '';
      #       };
      #       useridField = mkOption {
      #         type = types.str;
      #         example = "uid";
      #         description = lib.mdDoc ''
      #           LDAP field which is a unique identifier for users on HedgeDoc.
      #         '';
      #       };
      #       tlsca = mkOption {
      #         type = types.str;
      #         default = "/etc/ssl/certs/ca-certificates.crt";
      #         example = "server-cert.pem,root.pem";
      #         description = lib.mdDoc ''
      #           Root CA for LDAP TLS in PEM format.
      #         '';
      #       };
      #     };
      #   });
      #   default = null;
      #   description = lib.mdDoc "Configure the LDAP integration.";
      # };
    }; in lib.mkOption {
      type = lib.types.submodule {
        freeformType = settingsFormat.type;
        inherit options;
      };
      description = lib.mdDoc ''
        HedgeDoc configuration, see
        <https://docs.hedgedoc.org/configuration/>
        for documentation.
      '';
    };

    environmentFile = mkOption {
      type = with types; nullOr path;
      default = null;
      example = "/var/lib/hedgedoc/hedgedoc.env";
      description = lib.mdDoc ''
        Environment file as defined in {manpage}`systemd.exec(5)`.

        Secrets may be passed to the service without adding them to the world-readable
        Nix store, by specifying placeholder variables as the option value in Nix and
        setting these variables accordingly in the environment file.

        ```
          # snippet of HedgeDoc-related config
          services.hedgedoc.settings.dbURL = "postgres://hedgedoc:\''${DB_PASSWORD}@db-host:5432/hedgedocdb";
          services.hedgedoc.settings.minio.secretKey = "$MINIO_SECRET_KEY";
        ```

        ```
          # content of the environment file
          DB_PASSWORD=verysecretdbpassword
          MINIO_SECRET_KEY=verysecretminiokey
        ```

        Note that this file needs to be available on the host on which
        `HedgeDoc` is running.
      '';
    };

    package = mkPackageOption pkgs "hedgedoc" { };
  };

  config = mkIf cfg.enable {
    users.groups."hedgedoc" = { };
    users.users.${name} = {
      description = "HedgeDoc service user";
      group = name;
      isSystemUser = true;
    };

    systemd.services.hedgedoc = {
      description = "HedgeDoc Service";
      wantedBy = [ "multi-user.target" ];
      after = [ "networking.target" ];
      preStart = ''
        ${pkgs.envsubst}/bin/envsubst \
          -o /var/lib/${name}/config.json \
          -i ${prettyJSON cfg.settings}
      '';
      serviceConfig = {
        RuntimeDirectory = [ name ];
        # WorkingDirectory = "/var/lib/${}";
        # StateDirectory = [ cfg.workDir cfg.settings.uploadsPath ];
        ReadWriteDirectories = mkIf (cfg.settings ? "uploadsPath") [ cfg.settings.uploadsPath ];
        StateDirectory = [ name ];
        ExecStart = "${cfg.package}/bin/hedgedoc";
        EnvironmentFile = mkIf (cfg.environmentFile != null) [ cfg.environmentFile ];
        Environment = [
          "CMD_CONFIG_FILE=/var/lib/${name}/config.json"
          "NODE_ENV=production"
        ];
        Restart = "always";
        # DynamicUser = true;
        User = name;
        Group = name;

        # Hardening
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
        RemoveIPC = true;
        RestrictSUIDSGID = true;
        UMask = "0007";
        RestrictAddressFamilies = [ "AF_INET" "AF_INET6" ] ++ (lib.optional (cfg.settings.path != null) "AF_UNIX");
        SystemCallArchitectures = "native";
        SystemCallFilter = "~@clock @cpu-emulation @debug @keyring @module @mount @obsolete @raw-io @reboot @setuid @swap";
      };
    };
  };
}
