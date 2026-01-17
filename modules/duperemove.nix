{ config, lib, pkgs, ... }:
let
  cfg = config.services.duperemove;
in
{
  options.services.duperemove = {
    enable = lib.mkEnableOption "duplicate file removal timers";

    directories = lib.mkOption {
      description = "";
      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          enable = lib.mkEnableOption "" // {
            default = true;
            example = false;
          };
          package = lib.mkPackageOption pkgs "duperemove" { };
          onCalendar = lib.mkOption {
            type = with lib.types; nullOr str;
            default = "monthly";
            example = "Mon *-*-* 00:00:00";
          };
          arguments = lib.mkOption {
            type = with lib.types; attrsOf (oneOf [ str int bool ]);
            default = { };
            example = { };
          };
        };
      });
      default = { };
      example = { };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services = {
      "duperemove@" = {
        description = "File duplicate remover for %i";
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${lib.getExe pkgs.duperemove} /";

          RootDirectory = "%i";
          CacheDirectory = "duperemove";

          PrivateInternet = true;
          PrivateIPC = true;
        };
      };
    } // (lib.mapAttrs' (n: v: {
      name = "duperemove@${n}";
      value = {
        onCalendar = lib.mkIf (v.onCalendar != null) v.onCalendar;
        serviceConfig.ExecStart = let
          args = lib.cli.toCommandLineShellGNU { } v.arguments;
        in "${lib.getExe v.package} ${args}";
      };
    }) (cfg.filterAttrs (_: d: d.enable ) cfg.directories));
  };
}
