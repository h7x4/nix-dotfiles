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

    downloadsDirectory = lib.mkOption {
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

    mappings = lib.mkOption {
      type = let
        mappingType = lib.types.submodule ({ name, ... }: {
          options = {
            unitName = lib.mkOption {
              type = lib.types.str;
              description = ''
                The basename of the path/service unit responsible for this mapping
              '';
              default = "downloads-sorter@${name}";
              example = "downloads-sorter@asdf";
            };

            dir = lib.mkOption {
              type = lib.types.path;
              description = ''
                Absolute path to the directory where matching files should be moved.
              '';
              default = if builtins.substring 0 1 name == "/" then name else "${cfg.downloadsDirectory}/${name}";
              defaultText = ''
                if builtins.substring 0 1 name == "/" then name else "''${config.services.downloads-sorter.downloadsDirectory}/''${name}"
              '';
            };

            globs = lib.mkOption {
              type = with lib.types; listOf str;
              description = ''
                A list of globs that match the files that should be moved.
              '';
              example = [
                "*.jpg"
                "IMG_*_2020_*.png"
              ];
              apply = map (g: "${cfg.downloadsDirectory}/${g}");
            };

            createDirIfNotExists = lib.mkOption {
              type = lib.types.bool;
              description = ''
                Whether to create the target directory if it does not exist yet.

                Turn this off if you'd like the target directory to be a symlink or similar.
              '';
              default = true;
              example = false;
            };

            # TODO: allow specifying a dynamic filter together with a system path trigger in an attrset.
          };
        });
      in with lib.types; attrsOf (coercedTo (listOf str) (globs: { inherit globs; }) mappingType);
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
        "documents" = {
          createDirIfNotExists = false;
          globs = [ "*.pdf" ];
        };
        "/home/<user>/archives" = [ "*.rar" ];
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.user.paths = lib.mapAttrs' (dir: mapping: {
      name = mapping.unitName;
      value = {
        Install.WantedBy = [ "paths.target" ];
        Path = {
          PathExistsGlob = mapping.globs;
          Unit = "${mapping.unitName}.service";
          TriggerLimitIntervalSec = "1s";
          TriggerLimitBurst = "1";
        };
      };
    }) cfg.mappings;

    # TODO: deduplicate
    systemd.user.services = lib.mapAttrs' (dir: mapping: {
      name = mapping.unitName;
      value = {
        Unit.Description = "Downloads directory watchdog, sorts the downloads directory";
        Service = {
          Type = "oneshot";
          Slice = "background.slice";
          SyslogIdentifier = mapping.unitName;
          ExecStart = let
            script = pkgs.writeShellApplication {
              name = "downloads-sorter-${dir}.sh";
              runtimeInputs = [ pkgs.coreutils ];
              text = ''
                shopt -s nullglob

                FILES=(${builtins.concatStringsSep " " mapping.globs})

                for file in "''${FILES[@]}"; do
                  echo "$file -> ${mapping.dir}"
                  mv "$file" '${mapping.dir}'
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
      absolutePaths = lib.pipe cfg.mappings [
        builtins.attrValues
        (builtins.filter (m: m.createDirIfNotExists))
        (map (m: m.dir))
      ];
    in lib.genAttrs absolutePaths (_: {
      d = {
        user = config.home.username;
      };
    });
  };
}
