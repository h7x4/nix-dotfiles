{ secrets, ... }: {
  services.prometheus = {
    enable = true;
    port = secrets.ports.prometheus;

    scrapeConfigs = [
      {
        job_name = "synapse";
        scrape_interval = "15s";
        metrics_path = "/_synapse/metrics";
        static_configs = [
          {
            targets = [ "localhost:${toString secrets.ports.matrix.listener}" ];
          }
        ];
      }
      # {
      #   job_name = "minecraft";
      #   # scrape_interval = "15s";
      #   # metrics_path = "/_synapse/metrics";
      #   static_configs = [
      #     {
      #       targets = [ "${secrets.ips.crafty}:${toString secrets.ports.prometheus-crafty}" ];
      #       labels = {
      #         server_name = "my-minecraft-server";
      #       };
      #     }
      #   ];
      # }
    ];

    exporters = {
      # jitsi.enable = true;
      nginx.enable = true;
      nginxlog.enable = true;
      systemd.enable = true;
      # openldap
      # openvpn
      # nextcloud
      # influxdb
      # wireguard
      # postgres = {
      #   enable = true;
      # };
    };

    # globalConfig = {

    # };

  };
}
