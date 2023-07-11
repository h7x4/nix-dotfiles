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
      analytics.check_for_updates = false;
      server = {
        domain = "log.nani.wtf";
        # TODO: use socket
        # protocol = [ "socket" ];
        http_addr = "127.0.0.1";
        http_port = secrets.ports.grafana;
      };

      security = {
        disable_initial_admin_creation = true;
        cookie_secure = true;
        secret_key = secretFile "grafana/secretkey";
      };

      database = {
        type = "postgres";
        user = "grafana";
        host = "/var/run/postgresql";
        password = secretFile "postgres/grafana";
      };
    };
  };

  systemd.services.grafana = {
    requires = [ "postgresql.service" ];
  };
}
