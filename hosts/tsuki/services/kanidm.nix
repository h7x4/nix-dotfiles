{ pkgs, config, ... }: let
  cfg = config.services.kanidm;
in {
  systemd.services.kanidm = let
    certName = config.services.nginx.virtualHosts.${cfg.server.settings.domain}.useACMEHost;
  in {
    requires = [ "acme-order-renew-${certName}.service" ];
    serviceConfig.LoadCredential = let
      certDir = config.security.acme.certs.${certName}.directory;
    in [
      "fullchain.pem:${certDir}/fullchain.pem"
      "key.pem:${certDir}/key.pem"
    ];
    serviceConfig.BindPaths = [
      cfg.server.settings.online_backup.path
    ];
  };

  services.kanidm = {
    package = pkgs.kanidm_1_9;
    # enablePAM = true;
    server.settings = let
      credsDir = "/run/credentials/kanidm.service";
    in {
      enable = true;
      origin = "https://${cfg.server.settings.domain}";
      domain = "auth.nani.wtf";
      tls_chain = "${credsDir}/fullchain.pem";
      tls_key = "${credsDir}/key.pem";
      bindaddress = "127.0.0.1:8300";
      # log_level = "debug";
      online_backup = {
        path = "/data/backup/kanidm";
        schedule = "00 22 * * *";
        versions = 10;
      };
    };
  };

  environment = {
    systemPackages = [ cfg.package ];
    etc."kanidm/config".text = ''
      uri="https://auth.nani.wtf"
    '';
  };
}
