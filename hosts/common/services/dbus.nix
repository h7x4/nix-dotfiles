{ pkgs, ... }:
{
  services.dbus = {
    enable = true;
    packages = with pkgs; [
      gcr
      dconf
    ];
  };
}
