{ pkgs, config, ... }: let
  cfg = config.services.kanidm;
in {
  systemd.services.kanidm = let
    certName = config.services.nginx.virtualHosts.${cfg.serverSettings.domain}.useACMEHost;
  in {
    requires = [ "acme-finished-${certName}.target" ];
    serviceConfig.LoadCredential = let
      certDir = config.security.acme.certs.${certName}.directory;
    in [
      "fullchain.pem:${certDir}/fullchain.pem"
      "key.pem:${certDir}/key.pem"
    ];
    serviceConfig.BindPaths = [
      cfg.serverSettings.online_backup.path
    ];
  };

  services.kanidm = {
    # package = pkgs.kanidm;
    enableServer = true;
    # enablePAM = true;
    serverSettings = let
      credsDir = "/run/credentials/kanidm.service";
    in {
      origin = "https://${cfg.serverSettings.domain}";
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
