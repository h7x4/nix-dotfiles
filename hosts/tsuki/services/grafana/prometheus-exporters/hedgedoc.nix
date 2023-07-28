{ ... }:
{
  # Hedgedoc already exports at /metrics
  services.prometheus.scrapeConfigs = [{
    job_name = "hedgedoc";
    scrape_interval = "15s";
    metrics_path = "/metrics/hedgedoc";
    static_configs = [{
      targets = [ "localhost" ];
    }];
  }];
}
