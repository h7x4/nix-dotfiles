{ config, lib, ... }:
let
  cfg = config.programs.vscode;
in
{
  options.programs.vscode.autoUpdateExtensions = {
     enable = lib.mkEnableOption "" // {
      description = "Whether to automatically update mutably installed vscode extensions.";
    };

    onCalendar = lib.mkOption {
      type = lib.types.str;
      default = "daily";
      example = "weekly";
      # TODO: link to systemd manpage for format.
      description = "How often to update the database.";
    };
  };

  config = lib.mkIf (cfg.enable && cfg.autoUpdateExtensions.enable) {
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
        OnCalendar = cfg.autoUpdateExtensions.onCalendar;
        Persistent = true;
      };

      Install = {
        WantedBy = [ "timers.target" ];
      };
    };
  };
}
