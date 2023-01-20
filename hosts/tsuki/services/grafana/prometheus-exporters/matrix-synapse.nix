{ lib, config, ... }:
{
  services.prometheus.scrapeConfigs = 
    lib.pipe config.services.matrix-synapse-next.workers.instances [
      (lib.mapAttrsToList (_: v: v))
      # Add metrics for main process to the list of workers
      (x: x ++ [{ type = "master"; index = 1; settings.worker_listeners = [{ port = 9000; }]; }])
      (map (w: let
          port = lib.pipe w.settings.worker_listeners [
            lib.last
            (l: l.port)
            toString 
          ];
        in {
        job_name = "synapse-${port}";
        scrape_interval = "15s";
        metrics_path = "/_synapse/metrics";
        static_configs = [{
          targets = [ "localhost:${port}" ];
          labels = {
            instance = "matrix.nani.wtf";
            job = w.type;
            index = toString w.index;
          };
        }];
      }))
    ];
}
