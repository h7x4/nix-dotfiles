{ pkgs, config, lib, secrets, ... }:
{
  imports = [
    ./prometheus.nix
    ./loki.nix
  ];

  sops.secrets = lib.genAttrs
    [
      "postgres/grafana"
      "grafana/secretkey"
      "grafana/oauth2_secret"
    ]
    (lib.const rec {
      restartUnits = [ "grafana.service" ];
      owner = config.systemd.services.grafana.serviceConfig.User;
      group = config.users.users.${owner}.group;
    });

  services.grafana = {
    enable = true;
    dataDir = "${config.machineVars.dataDrives.default}/var/grafana";

    provision = {
      enable = true;

      datasources.settings.datasources = [
        {
          name = "Prometheus";
          type = "prometheus";
          access = "proxy";
          url = "http://localhost:${toString config.services.prometheus.port}";
          isDefault = true;
        }
      ];

      dashboards.settings.providers = let
        makeReadOnly = x: lib.pipe x [
          builtins.readFile
          builtins.fromJSON
          (x: x // { editable = false; })
          builtins.toJSON
          (pkgs.writeText (builtins.baseNameOf x))
        ];
      in [
        {
          name = "Matrix Synapse";
          type = "file";
          url = "https://raw.githubusercontent.com/matrix-org/synapse/develop/contrib/grafana/synapse.json";
          options.path = makeReadOnly ./dashboards/matrix-synapse.json;
        }
        {
          name = "PostgreSQL";
          type = "file";
          url = "https://grafana.com/api/dashboards/9628/revisions/7/download";
          options.path = makeReadOnly ./dashboards/postgres.json;
        }
        {
          name = "Node";
          type = "file";
          url = "https://raw.githubusercontent.com/rfmoz/grafana-dashboards/master/prometheus/node-exporter-full.json";
          options.path = makeReadOnly ./dashboards/node.json;
        }
        {
          name = "Nginx";
          type = "file";
          url = "https://raw.githubusercontent.com/nginxinc/nginx-prometheus-exporter/main/grafana/dashboard.json";
          options.path = makeReadOnly ./dashboards/nginx.json;
        }
        # TODO: activate when php-fpm exporter is backported
        # {
        #   name = "php-fpm";
        #   type = "file";
        #   url = "https://raw.githubusercontent.com/hipages/php-fpm_exporter/master/grafana/kubernetes-php-fpm.json";
        #   options.path = makeReadOnly ./dashboards/php-fpm.json;
        # }
        
        # See https://github.com/grafana/grafana/issues/10786

        {
          name = "Redis";
          type = "file";
          url = "https://raw.githubusercontent.com/oliver006/redis_exporter/master/contrib/grafana_prometheus_redis_dashboard.json";
          options.path = ./dashboards/redis.json;
        }
        # {
        #   name = "Minecraft";
        #   options.path = makeReadOnly ./dashboards/minecraft.json;
        # }
      ];
    };

    settings = let
      secretFile = sopsKey: ''$__file{${config.sops.secrets.${sopsKey}.path}}'';
    in {
      server = {
        domain = "log.nani.wtf";
        root_url = "https://log.nani.wtf";
        enforce_domain = true;
        enable_gzip = true;
        protocol = "socket";
        socket = "/run/grafana/grafana.sock";
      };

      security = {
        cookie_secure = true;
        csrf_trusted_origins = [ "https://auth.nani.wtf" ];
        data_source_proxy_whitelist = [
          (with config.services.prometheus; "${listenAddress}:${toString port}")
        ];
        disable_gravatar = true;
        disable_initial_admin_creation = true;
        secret_key = secretFile "grafana/secretkey";
      };

      database = {
        type = "postgres";
        user = "grafana";
        host = "/var/run/postgresql";
        password = secretFile "postgres/grafana";
      };

      auth = {
        # disable_login_form = true;
      };

      "auth.generic_oauth" = let
        authServerUrl = config.services.kanidm.serverSettings.origin;
      in {
        enabled = true;
        name = "KaniDM";
        client_id = "grafana";
        client_secret = secretFile "grafana/oauth2_secret";
        auth_url = "${authServerUrl}/ui/oauth2";
        token_url = "${authServerUrl}/oauth2/token";
        api_url = "${authServerUrl}/oauth2/authorise";
        scopes = "email openid profile";
        auto_login = true;
        use_pkce = true;

        # I only have one user, and that one user should always be admin,
        # no matter what kanidm sends.
        role_attribute_strict = true;
        role_attribute_path = "contains(info.groups[*], 'grafana_users') && 'GrafanaAdmin' || 'Viewer'";
        allow_assign_grafana_admin = true;
      };

      analytics = {
        check_for_updates = false;
        feedback_links_enabled = false;
        reporting_enabled = false;
      };
    };
  };

  users.groups."grafana".members = [ "nginx" ];

  systemd.services.grafana = {
    requires = [ "postgresql.service" ];
  };
}
