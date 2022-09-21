{ pkgs, unstable-pkgs, secrets, ... }:
{
  # Follow instructions for setup:
  # https://gist.github.com/joepie91/c26f01a787af87a96f967219234a8723
  services.hydra = {
    enable = true;
    hydraURL = "http://hydra.nani.wtf";
    notificationSender = "hydra@nani.wtf";
    useSubstitutes = true;
    package = unstable-pkgs.hydra_unstable;
    port = secrets.ports.hydra;
    buildMachinesFiles = [];
  };
}
