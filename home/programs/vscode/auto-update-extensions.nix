{ config, lib, ... }:
let
  cfg = config.programs.vscode;
in
lib.mkIf cfg.enable {
  # TODO: add `dirname` to $PATH upstream
  systemd.user.services.update-vscode-extensions = {
    Unit = {
      Description = "Update vscode extensions";
    };

    Service = {
      Type = "oneshot";
      CPUSchedulingPolicy = "idle";
      IOSchedulingClass = "idle";
      ExecStart = "${lib.getExe cfg.package} --update-extensions";
    };
  };

  systemd.user.timers.update-vscode-extensions = {
    Unit = {
      Description = "Update vscode extensions";
    };

    Timer = {
      Unit = "update-vscode-extensions.service";
      OnCalendar = "daily";
      Persistent = true;
    };

    Install = {
      WantedBy = [ "timers.target" ];
    };
  };
}
