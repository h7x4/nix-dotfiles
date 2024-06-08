{ config, pkgs, lib, ... }:
{
  services.screen-locker = {
    enable = true;
    lockCmd = lib.getExe pkgs.i3lock-fancy;
  };
}
