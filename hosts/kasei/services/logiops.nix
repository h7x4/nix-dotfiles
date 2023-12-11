{ pkgs, ... }:
{
  # TODO: remove when merged: https://github.com/NixOS/nixpkgs/pull/167388
  systemd.services = {
    logid = {
      description = "Logitech Configuration Daemon";
      startLimitIntervalSec = 0;
      wants = [ "multi-user.target" ];
      after = [ "multi-user.target" ];
      wantedBy = [ "graphical-session.target" ];
    
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.logiops}/bin/logid";
        User = "root";
        ExecReload = "/bin/kill -HUP $MAINPID";
        Restart="on-failure";
      };
    };
  };

  hardware.logitech.wireless.enable = true;
}
