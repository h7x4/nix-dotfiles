{ ... }:
{
  services.prometheus.scrapeConfigs = [{
    job_name = "minecraft";
    scrape_interval = "15s";
    static_configs = [
      {
        targets = [ "localhost:9225" ];
        labels = {
          server_name = "kakuland";
        };
      }
    ];
  }];
}
