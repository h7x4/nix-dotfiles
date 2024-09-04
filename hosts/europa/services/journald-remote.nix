{ ... }:
{
  services.journald.upload = {
    enable = true;
    settings.Upload = {
      URL = "https://10.250.14.105:19532";
      # ServerKeyFile = toString ./key.pem;
      # ServerCertificateFile = toString ./cert.pem;
      ServerKeyFile = "-";
      ServerCertificateFile = "-";
      TrustedCertificateFile = "-";
    };
  };  
}
