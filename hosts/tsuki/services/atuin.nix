{ config, ... }:
let
  cfg = config.services.atuin;
in
{
  services.atuin = {
    enable = true;
    openRegistration = false;
  };

  systemd.services.atuin.requires = [ "postgresql.service" ];

  local.socketActivation.atuin = {
    enable = cfg.enable;
    originalSocketAddress = "${cfg.host}:${toString cfg.port}";
    newSocketAddress = "/run/atuin.sock";
    privateNamespace = false;
  };
}
