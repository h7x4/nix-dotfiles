{ config, lib, pkgs, ... }:
let
  cfg = config.services.downloads-sorter;
in
{
  imports = [
    ../systemd-tmpfiles.nix
  ];

  options.services.downloads-sorter = {
    enable = lib.mkEnableOption "downloads sorter units, path activated units to keep the download dir clean";

    downloadsDir = lib.mkOption {
      type = lib.types.path;
      description = "Which directory to keep clean";
      default = if config.xdg.userDirs.enable then config.xdg.userDirs.download else "${config.home.homeDirectory}/Downloads";
      defaultText = ''
        if config.xdg.userDirs.enable then config.xdg.userDirs.download else "''${config.home.homeDirectory}/Downloads"
      '';
      example = ''
        "''${config.home.homeDirectory}/downloads"
      '';
    };

    # TODO: allow specifying a dynamic filter together with a system path trigger in an attrset.
    mappings = lib.mkOption {
      type = with lib.types; attrsOf (listOf str);
      description = ''
        A mapping from a file pattern to the location where it should be moved.

        By default, the output mapping is relative to the download dir.
        If an absolute path is given, the sorter will move the files out of the downloads dir.
      '';
      default = { };
      example = {
        "pictures" = [
          "*.png"
          "*.jpg"
        ];
        "documents" = [ "*.pdf" ];
        "/home/<user>/archives" = [ "*.rar" ];
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.user.paths = lib.mapAttrs' (dir: globs: let
      unitName = "downloads-sorter@${dir}";
    in {
      name = unitName;
      value = {
        Install.WantedBy = [ "paths.target" ];
        Path = {
          PathExistsGlob = map (g: "${cfg.downloadsDir}/${g}") globs;
          Unit = "${unitName}.service";
          TriggerLimitIntervalSec = "1s";
          TriggerLimitBurst = "1";
        };
      };
    }) cfg.mappings;

    # TODO: deduplicate
    systemd.user.services = lib.mapAttrs' (dir: globs: let
      unitName = "downloads-sorter@${dir}";
    in {
      name = unitName;
      value = {
        Unit.Description = "Downloads directory watchdog, sorts the downloads directory";
        Service = {
          Type = "oneshot";
          SyslogIdentifier = unitName;
          ExecStart = let
            absolutePath = if (builtins.substring 0 1 dir) == "/" then dir else "${cfg.downloadsDir}/${dir}";

            script = pkgs.writeShellApplication {
              name = "downloads-sorter-${dir}.sh";
              runtimeInputs = [ pkgs.coreutils ];
              text = ''
                shopt -s nullglob

                FILES=(${lib.concatMapStringsSep " " (g: "'${cfg.downloadsDir}'/${g}") globs})

                for file in "''${FILES[@]}"; do
                  echo "$file -> ${absolutePath}"
                  mv "$file" '${absolutePath}'
                done
              '';
            };
          in lib.getExe script;

          PrivateUsers = true;
          ProtectSystem = true;
          NoNewPrivileges = true;
          ProtectKernelTunables = true;
          ProtectControlGroups = true;
          PrivateNetwork = true;
          RestrictNamespaces = true;
        };
      };
    })  cfg.mappings;

    systemd.user.tmpfiles.settings."10-downloads-sorter-service" = let
      absolutePaths = map (p: if (builtins.substring 0 1 p) == "/" then p else "${cfg.downloadsDir}/${p}") (builtins.attrNames cfg.mappings);
    in lib.genAttrs absolutePaths (_: {
      d = {
        user = config.home.username;
      };
    });
  };
}
