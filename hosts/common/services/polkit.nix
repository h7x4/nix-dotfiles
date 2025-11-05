{ config, lib, ... }:
let
  cfg = config.security.polkit;
in
{
  systemd.services.polkit.serviceConfig = lib.mkIf cfg.enable {
    RuntimeDirectory = [
      "polkit-1"
      "polkit-1/root-mnt"
    ];
    RootDirectory = "/run/polkit-1/root-mnt";
    BindPaths = [ "/run/dbus/system_bus_socket" ];
    BindReadOnlyPaths = [
      builtins.storeDir
      "/etc"
      "/run/systemd"
      "/run/current-system/sw/share/polkit-1"
    ];
  };
}
