{ pkgs, lib, ... }:
{
  # programs.usbtop.enable = true;

  boot.kernelModules = [ "usbmon" ];

  security.wrappers."usbtop" = {
    owner = "root";
    group = "usbmon";
    setgid = true;
    source = lib.getExe pkgs.usbtop;
  };

  users.groups.usbmon = {
    # NOTE: picked at random
    gid = 872;
  };

  services.udev.extraRules = ''
    SUBSYSTEM=="usbmon", MODE="0660", OWNER="root", GROUP="usbmon"
  '';
}
