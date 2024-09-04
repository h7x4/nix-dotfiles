{ ... }:
{
  # TODO: Reproducible certificates
  services.journald.remote = {
    enable = true;
    settings.Remote = {
      # ServerKeyFile = "/run/credentials/systemd-journald-remote.service/key.pem";
      # ServerCertificateFile = "/run/credentials/systemd-journald-remote.service/.pem";
      ServerKeyFile = "/etc/journald-remote-certs/key.pem";
      ServerCertificateFile = "/etc/journald-remote-certs/cert.pem";
      TrustedCertificateFile = "-";
    };
  };

  # systemd.services.systemd-journal-remote.serviceConfig.LoadCredential = [
  #   "key.pem:/etc/journald-remote-certs/key.pem"
  #   "cert.pem:/etc/journald-remote-certs/cert.pem"
  # ];
}
