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
  };

  services.kanidm = {
    enableServer = true;
    # enablePAM = true;
    serverSettings = let
      credsDir = "/run/credentials/kanidm.service";
    in {
      origin = "https://${cfg.serverSettings.domain}";
      domain = "auth.nani.wtf";
      tls_chain = "${credsDir}/fullchain.pem";
      tls_key = "${credsDir}/key.pem";
      bindaddress = "localhost:8300";
    };
  };

  environment = {
    systemPackages = [ pkgs.kanidm ];
    etc."kanidm/config".text = ''
      uri="https://auth.nani.wtf"
    '';
  }; 
}
