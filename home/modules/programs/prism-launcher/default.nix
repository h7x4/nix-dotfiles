{ config, pkgs, lib, ... }:
let
  cfg = config.programs.prism-launcher;

  screenshotPathGlob = "${config.xdg.dataHome}/PrismLauncher/instances/*/.minecraft/screenshots";
in
{
  options.programs.prism-launcher = {
    enable = lib.mkEnableOption "PrismLauncher, an open source minecraft launcher";

    package = lib.mkPackageOption pkgs "prismlauncher" { };

    screenshotMover = {
      enable = lib.mkEnableOption "a systemd unit that automatically moves screenshots from all minecraft instances into a common dir";

      screenshotDir = lib.mkOption {
        description = "Where to move the minecraft screenshots.";
        type = lib.types.path;
        # TODO: priority list:
        #         - userDirs pictures
        #         - homeDir Pictures
        default = "${config.xdg.userDirs.pictures}/prismlauncher-screenshots";
        # TODO: Literal expression for default
        example = lib.literalExpression ''
          "''${config.home.homeDirectory}/minecraftScreenshots"
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];

    systemd.user.paths.prismlauncher-move-minecraft-screenshots = lib.mkIf cfg.screenshotMover.enable {
      Install.WantedBy = [ "paths.target" ];
      Unit.Description = "Watchdog that moves screenshots from all prismlauncher minecraft instances into a common dir";
      Path = {
        PathChanged = [ screenshotPathGlob ];
        Unit = "prismlauncher-move-minecraft-screenshots.service";
        TriggerLimitIntervalSec = "1s";
        TriggerLimitBurst = "1";
      };
    };

    systemd.user.services.prismlauncher-move-minecraft-screenshots = lib.mkIf cfg.screenshotMover.enable {
      Unit.Description = "Watchdog that moves screenshots from all prismlauncher minecraft instances into a common dir";
      Service = {
        Type = "oneshot";
        # TODO: expand glob inside a shell
        ExecStart = "${pkgs.coreutils}/bin/mv ${screenshotPathGlob} '${cfg.screenshotMover.screenshotDir}'";

        PrivateUsers = true;
        ProtectSystem = true;
        NoNewPrivileges = true;
        ProtectKernelTunables = true;
        ProtectControlGroups = true;
        RestrictAddressFamilies = [ ];
        RestrictNamespaces = true;
      };
    };
  };
}
