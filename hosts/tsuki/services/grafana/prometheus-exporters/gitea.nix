{ ... }:
{
  # Gitea already exports at /metrics
  services.prometheus.scrapeConfigs = [{
    job_name = "gitea";
    scrape_interval = "15s";
    metrics_path = "/metrics/gitea";
    static_configs = [{
      targets = [ "localhost" ];
    }];
  }];
}
