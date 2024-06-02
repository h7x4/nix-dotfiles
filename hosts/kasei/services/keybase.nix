{ config, pkgs, lib, ... }:
{
  services.keybase.enable = true;

  services.kbfs = {
    enable = true;
    extraFlags = [
      "-label kbfs"
      "-mount-type normal"
    ];
    # enableRedirector = true;
  };

  environment.systemPackages = with pkgs; [ keybase keybase-gui kbfs ];
}
