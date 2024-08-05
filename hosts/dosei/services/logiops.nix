{ pkgs, ... }:
{
  # TODO: remove when merged: https://github.com/NixOS/nixpkgs/pull/167388
  systemd.services.logid = let
    config = pkgs.writeText "logid.cfg" ''
      devices: (
      {
          name: "Wireless Mouse MX Master";
          smartshift:
          {
              on: true;
              threshold: 30;
              torque: 50;
          };
          hiresscroll:
          {
              hires: true;
              invert: false;
              target: true;
              up: {
                  mode: "Axis";
                  axis: "REL_WHEEL_HI_RES";
                  multiplier: 1;
              },
              down: {
                  mode: "Axis";
                  axis: "REL_WHEEL_HI_RES";
                  multiplier: -1;
              },
          };
          dpi: 800;
      }
      );
    '';
  in {
      description = "Logitech Configuration Daemon";
      startLimitIntervalSec = 0;
      wants = [ "multi-user.target" ];
      after = [ "multi-user.target" ];
      wantedBy = [ "graphical-session.target" ];

      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.logiops}/bin/logid --config ${config}";
        User = "root";
        ExecReload = "/bin/kill -HUP $MAINPID";
        Restart="on-failure";
      };
  };

  hardware.logitech.wireless.enable = true;
}
