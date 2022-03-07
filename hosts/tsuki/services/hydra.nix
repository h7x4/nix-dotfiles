{ secrets, ... }:
{
  services.hydra = {
    enable = true;
    hydraURL = "http://hydra.nani.wtf";
    notificationSender = "hydra@nani.wtf";
    port = secrets.ports.hydra;
  };
}
