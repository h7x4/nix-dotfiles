{ config, pkgs, lib, ... }:
let
  cfg = config.services.uptimed;
in
{
  options.services.uptimed.settings = lib.mkOption {
    description = "";
    default = { };
    type = lib.types.submodule {
      freeformType = with lib.types; attrsOf (either str (listOf str));
    };
  };

  config = {
    services.uptimed = {
      enable = true;

      settings = let
        stateDir = "/var/lib/uptimed";
      in {
        PIDFILE = "${stateDir}/pid";
        SENDMAIL = lib.mkDefault "${pkgs.system-sendmail}/bin/sendmail -t";
      };
    };

    systemd.services.uptimed = lib.mkIf (cfg.enable) {
      serviceConfig = let
        uptimed = pkgs.uptimed.overrideAttrs (prev: {
          postPatch = ''
             substituteInPlace Makefile.am \
               --replace-fail '$(sysconfdir)/uptimed.conf' '/var/lib/uptimed/uptimed.conf'
             substituteInPlace src/Makefile.am \
               --replace-fail '$(sysconfdir)/uptimed.conf' '/var/lib/uptimed/uptimed.conf'
          '';
        });

      in {
        Type = "notify";

        ExecStart = lib.mkForce "${uptimed}/sbin/uptimed -f";

        BindReadOnlyPaths = let
          configFile = lib.pipe cfg.settings [
            (lib.mapAttrsToList
              (k: v:
                if builtins.isList v
                  then lib.mapConcatStringsSep "\n" (v': "${k}=${v'}") v
                  else "${k}=${v}")
            )
            (lib.concatStringsSep "\n")
            (pkgs.writeText "uptimed.conf")
          ];
        in [
          "${configFile}:/var/lib/uptimed/uptimed.conf"
        ];
      };
    };
  };
}
