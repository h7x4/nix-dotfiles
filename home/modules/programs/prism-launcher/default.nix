{ config, pkgs, lib, ... }:
let
  cfg = config.programs.prism-launcher;
in
{
  options.programs.prism-launcher = {
    enable = lib.mkEnableOption "PrismLauncher, an open source minecraft launcher";

    package = lib.mkPackageOption pkgs "prismlauncher" { };

    stateDir = lib.mkOption {
      description = "The directory where PrismLauncher stores it's state";
      type = lib.types.path;
      default = "${config.xdg.dataHome}/PrismLauncher";
      defaultText = lib.literalExpression ''"''${config.xdg.dataHome}/PrismLauncher"'';
    };

    screenshotMover = {
      enable = lib.mkEnableOption "a systemd unit that automatically moves screenshots from all minecraft instances into a common dir";

      screenshotDir = lib.mkOption {
        description = "Where to move the minecraft screenshots.";
        type = lib.types.path;
        default = if config.xdg.userDirs.pictures != null
          then "${config.xdg.userDirs.pictures}/prismlauncher-screenshots"
          else "${config.home.homeDirectory}/Pictures";
        defaultText = lib.literalExpression ''
          if config.xdg.userDirs.pictures != null
            then "''${config.xdg.userDirs.pictures}/prismlauncher-screenshots"
            else "''${config.home.homeDirectory}/Pictures"
        '';
        example = lib.literalExpression ''
          "''${config.home.homeDirectory}/minecraft-screenshots"
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
        PathExistsGlob = [ "${cfg.stateDir}/instances/*/.minecraft/screenshots/*.png" ];
        Unit = "prismlauncher-move-minecraft-screenshots.service";
        TriggerLimitIntervalSec = "1s";
        TriggerLimitBurst = "1";
      };
    };

    systemd.user.services.prismlauncher-move-minecraft-screenshots = lib.mkIf cfg.screenshotMover.enable {
      Unit.Description = "Watchdog that moves screenshots from all prismlauncher minecraft instances into a common dir";
      Service = {
        Type = "oneshot";
        ExecStart = lib.getExe (pkgs.writeShellApplication {
          name = "prismlauncher-move-minecraft-screenshots.sh";
          runtimeInputs = with pkgs; [ coreutils findutils ];
          text = let
            instancesDir = "${cfg.stateDir}/instances";
          in ''
            shopt -s nullglob

            for idir in "${instancesDir}"/*/; do
              INSTANCE_NAME="''${idir#${instancesDir}/}"
              INSTANCE_NAME="''${INSTANCE_NAME%'/'}"
              SCREENSHOT_TARGET_DIR="${cfg.screenshotMover.screenshotDir}/$INSTANCE_NAME"
              mkdir -p "''${SCREENSHOT_TARGET_DIR}"
              if [ -d "${instancesDir}/$INSTANCE_NAME"/.minecraft/screenshots ]; then
              for screenshot in "${instancesDir}/$INSTANCE_NAME"/.minecraft/screenshots/*.png; do
                echo "Moving '$screenshot' -> '$SCREENSHOT_TARGET_DIR'"
                cp --preserve=all "$screenshot" "$SCREENSHOT_TARGET_DIR"
                rm "$screenshot"
              done
              fi
            done
          '';
        });

        PrivateUsers = true;
        PrivateNetwork = true;
        ProtectSystem = true;
        NoNewPrivileges = true;
        ProtectKernelTunables = true;
        ProtectControlGroups = true;
        RestrictAddressFamilies = [ ];
        RestrictNamespaces = true;
      };
    };

    systemd.user.tmpfiles.rules = lib.mkIf cfg.screenshotMover.enable [
      "'d' '${cfg.screenshotMover.screenshotDir}' - ${config.home.username} - - -"
    ];
  };
}
