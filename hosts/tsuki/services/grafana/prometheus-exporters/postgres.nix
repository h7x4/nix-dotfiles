{ ... }:
{
  services.prometheus = {
    scrapeConfigs = [{
      job_name = "postgres";
      scrape_interval = "15s";
      static_configs = [
        {
          targets = [ "localhost:10392" ];
        }
      ];
    }];

    exporters.postgres = {
      enable = true;
      port = 10392;
      runAsLocalSuperUser = true;
      extraFlags = [ "--auto-discover-databases" ];
    };
  };

  systemd.services.prometheus-postgres-exporter.serviceConfig.Slice = "system-prometheus.slice";
}
