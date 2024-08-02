{ config, pkgs, lib, ... }:
let
  cfg = config.programs.gpg;
in
{
  # TODO: Create proper descriptions
  options = {
    programs.gpg.fetch-keys = {
      enable = lib.mkEnableOption "auto fetching of gpg keys by fingerprint";
      keys = lib.mkOption {
        description = "";
        default = { };
        type = lib.types.attrsOf (lib.types.submodule ({ name, ... }: {
          options = {
            id = lib.mkOption {
              description = "";
              default = name;
              example = "";
              type = lib.types.str;
            };

            keyserver = lib.mkOption {
              description = "If marked as null, use config";
              default = null;
              example = "hkps://keys.openpgp.org";
              type = with lib.types; nullOr str;
              apply = v: if v == null then "@NULL@" else v;
            };

            trust = lib.mkOption {
              description = "If marked as null, it's mutable";
              default = null;
              example = 4;
              type = with lib.types; nullOr (ints.between 1 5);
            };
          };
        }));
      };
    };
  };

  config = {
    # TODO: Fix the module so that this unit runs whenever something changes
    systemd.user.services.gpg-fetch-keys = let
      fetchKeysApplication = let
        recvKeysByKeyserver = lib.pipe cfg.fetch-keys.keys [
          lib.attrValues
          (lib.foldl (acc: key: acc // {
            ${key.keyserver} = (acc.${key.keyserver} or []) ++ [ key.id ];
          }) { })
          (lib.mapAttrsToList (keyserver: ids:
            if keyserver == "@NULL@"
              then "gpg --recv-keys ${lib.escapeShellArgs ids}"
              else "gpg --keyserver ${lib.escapeShellArg keyserver} --recv-keys ${lib.escapeShellArgs ids}"))
          (lib.concatStringsSep "\n")
        ];

        # Taken from modules/programs/gpg.nix
        # Slightly modified in order not to read files
        importTrustBashFunctions = let
          gpg = "${cfg.package}/bin/gpg";
        in ''
          function importTrust() {
            local keyId trust
            keyId="$1"
            trust="$2"
            { echo trust; echo "$trust"; (( trust == 5 )) && echo y; echo quit; } \
              | ${gpg} --no-tty --command-fd 0 --edit-key "$keyId"
          }
        '';

        trustKeys = lib.pipe cfg.fetch-keys.keys [
          lib.attrValues
          (lib.filter (key: key.trust != null))
          (map ({ id, trust, ... }: "importTrust '${id}' '${toString trust}'"))
          (lib.concatStringsSep "\n")
        ];
      in pkgs.writeShellApplication {
        name = "fetch-gpg-keys";
        runtimeInputs = [ cfg.package ];
        text = lib.concatStringsSep "\n" [
          recvKeysByKeyserver
          importTrustBashFunctions
          trustKeys
        ];
      };
    in lib.mkIf cfg.fetch-keys.enable {
      Unit = {
        Description = "Fetch declaratively listed gpg keys";
        Documentation = [ "man:gpg(1)" ];
        X-Restart-Triggers = [ "${fetchKeysApplication}" ];
        X-SwitchMethod = "restart";
      };

      Service = {
        Type = "oneshot";
        CPUSchedulingPolicy = "idle";
        IOSchedulingClass = "idle";
        ExecStart = "${lib.getExe fetchKeysApplication}";

        Environment = [
          "GNUPGHOME=${cfg.homedir}"
        ];
      };
    };
  };
}
