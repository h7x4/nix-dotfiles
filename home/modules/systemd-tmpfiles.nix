# Taken from nixpkgs: nixos/modules/system/boot/systemd/tmpfiles.nix
{ config, pkgs, lib, unstable-pkgs, ... }:
let
  # TODO: 24.05, year of the types.attrsWith
  inherit (unstable-pkgs.lib) types mkOption;

  cfg = config.systemd.user.tmpfiles;

  attrsWith' =
    placeholder: elemType:
    types.attrsWith {
      inherit elemType;
      inherit (lib) placeholder;
    };

  escapeArgument = lib.strings.escapeC [
    "\t"
    "\n"
    "\r"
    " "
    "\\"
  ];

  settingsOption = {
    description = ''
      Declare systemd-tmpfiles rules to create, delete, and clean up volatile
      and temporary files and directories.

      Even though the service is called `*tmp*files` you can also create
      persistent files.
    '';
    example = {
      "10-mypackage" = {
        "/var/lib/my-service/statefolder".d = {
          mode = "0755";
          user = "root";
          group = "root";
        };
      };
    };
    default = { };
    type = attrsWith' "config-name" (
      attrsWith' "path" (
        attrsWith' "tmpfiles-type" (
          lib.types.submodule (
            { name, config, ... }:
            {
              options.type = mkOption {
                type = types.str;
                default = name;
                defaultText = "‹tmpfiles-type›";
                example = "d";
                description = ''
                  The type of operation to perform on the file.

                  The type consists of a single letter and optionally one or more
                  modifier characters.

                  Please see the upstream documentation for the available types and
                  more details:
                  {manpage}`tmpfiles.d(5)`
                '';
              };
              options.mode = mkOption {
                type = types.str;
                default = "-";
                example = "0755";
                description = ''
                  The file access mode to use when creating this file or directory.
                '';
              };
              options.user = mkOption {
                type = types.str;
                default = "-";
                example = "root";
                description = ''
                  The user of the file.

                  This may either be a numeric ID or a user/group name.

                  If omitted or when set to `"-"`, the user and group of the user who
                  invokes systemd-tmpfiles is used.
                '';
              };
              options.group = mkOption {
                type = types.str;
                default = "-";
                example = "root";
                description = ''
                  The group of the file.

                  This may either be a numeric ID or a user/group name.

                  If omitted or when set to `"-"`, the user and group of the user who
                  invokes systemd-tmpfiles is used.
                '';
              };
              options.age = mkOption {
                type = types.str;
                default = "-";
                example = "10d";
                description = ''
                  Delete a file when it reaches a certain age.

                  If a file or directory is older than the current time minus the age
                  field, it is deleted.

                  If set to `"-"` no automatic clean-up is done.
                '';
              };
              options.argument = mkOption {
                type = types.str;
                default = "";
                example = "";
                description = ''
                  An argument whose meaning depends on the type of operation.

                  Please see the upstream documentation for the meaning of this
                  parameter in different situations:
                  {manpage}`tmpfiles.d(5)`
                '';
              };
            }
          )
        )
      )
    );
  };

  # generates a single entry for a tmpfiles.d rule
  settingsEntryToRule = path: entry: ''
    '${entry.type}' '${path}' '${entry.mode}' '${entry.user}' '${entry.group}' '${entry.age}' ${escapeArgument entry.argument}
  '';

  # generates a list of tmpfiles.d rules from the attrs (paths) under tmpfiles.settings.<name>
  pathsToRules = lib.mapAttrsToList (
    path: types: lib.concatStrings (lib.mapAttrsToList (_type: settingsEntryToRule path) types)
  );

  mkRuleFileContent = paths: lib.concatStrings (pathsToRules paths);
in
{
  options.systemd.user.tmpfiles.settings = lib.mkOption settingsOption;

  config = lib.mkIf (cfg.settings != { }) {
    assertions = [
      (lib.hm.assertions.assertPlatform "systemd.user.tmpfiles" pkgs
        lib.platforms.linux)
    ];

    xdg.configFile = {
      "systemd/user/basic.target.wants/systemd-tmpfiles-setup.service".source =
        "${pkgs.systemd}/example/systemd/user/systemd-tmpfiles-setup.service";
      "systemd/user/systemd-tmpfiles-setup.service".source =
        "${pkgs.systemd}/example/systemd/user/systemd-tmpfiles-setup.service";
      "systemd/user/timers.target.wants/systemd-tmpfiles-clean.timer".source =
        "${pkgs.systemd}/example/systemd/user/systemd-tmpfiles-clean.timer";
      "systemd/user/systemd-tmpfiles-clean.service".source =
        "${pkgs.systemd}/example/systemd/user/systemd-tmpfiles-clean.service";
    } // (lib.mapAttrs' (name: paths: {
      name = "user-tmpfiles.d/${name}.conf";
      value = {
        text = mkRuleFileContent paths;
        onChange = "${pkgs.systemd}/bin/systemd-tmpfiles --user --create";
      };
    }) cfg.settings);
  };
}
