{ config, lib, ... }:
let
  cfg = config.services.irqbalance;
in
{
  services.irqbalance.enable = true;

  systemd.services.irqbalance.serviceConfig = lib.mkIf cfg.enable {
    RuntimeDirectory = [
      "irqbalance"
      "irqbalance/root-mnt"
    ];

    RootDirectory = "/run/irqbalance/root-mnt";
    BindReadOnlyPaths = [
      builtins.storeDir
    ];
    # NoExecPaths = "/";
    # ExecPaths = lib.getExe cfg.package;
  };
}
