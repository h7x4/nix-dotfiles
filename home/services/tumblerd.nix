{ config, pkgs, lib, ... }:
let
  package = pkgs.xfce.tumbler;
in
{
  systemd.user.services.tumblerd = {
    Unit = {
      Description = "Thumbnailing service";
    };

    Service = {
      Type = "dbus";
      BusName = "org.freedesktop.thumbnails.Thumbnailer1";
      ExecStart = "${package}/lib/tumbler-1/tumblerd";
    };
  };

  xdg.dataFile = {
    "dbus-1/services/org.xfce.Tumbler.Cache1.service".source = "${package}/share/dbus-1/services/org.xfce.Tumbler.Cache1.service";
    "dbus-1/services/org.xfce.Tumbler.Manager1.service".source = "${package}/share/dbus-1/services/org.xfce.Tumbler.Manager1.service";
    "dbus-1/services/org.xfce.Tumbler.Thumbnailer1.service".source = "${package}/share/dbus-1/services/org.xfce.Tumbler.Thumbnailer1.service";
  };

  # TODO: configure properly
  xdg.configFile."tumbler/tumbler.rc".source = "${package}/etc/xdg/tumbler/tumbler.rc";
}
