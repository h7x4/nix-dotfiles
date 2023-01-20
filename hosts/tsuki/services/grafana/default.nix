{ pkgs, config, lib, secrets, ... }:
{
  imports = [
    ./prometheus.nix
    ./loki.nix
  ];

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
          options.path = makeReadOnly ./dashboards/matrix-synapse.json;
        }
        {
          name = "PostgreSQL";
          options.path = makeReadOnly ./dashboards/postgres.json;
        }
        {
          name = "Node";
          options.path = makeReadOnly ./dashboards/node.json;
        }
        
        # See https://github.com/grafana/grafana/issues/10786

        # {
        #   name = "Redis";
        #   options.path = ./dashboards/redis.json;
        # }
        # {
        #   name = "Minecraft";
        #   options.path = makeReadOnly ./dashboards/minecraft.json;
        # }
      ];
    };

    settings = {
      server = {
        domain = "log.nani.wtf";
        http_addr = "0.0.0.0";
        http_port = secrets.ports.grafana;
      };

      database = {
        type = "postgres";
        user = "grafana";
        host = "localhost:${toString secrets.ports.postgres}";
      };
    };
  };
}
