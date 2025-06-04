{ config, lib, ... }:
let
  cfg = config.services.gnome-keyring;
in
lib.mkIf cfg.enable {
  services.gnome-keyring = { };

  systemd.user.services.gnome-keyring.Service.Slice = lib.mkIf cfg.enable "session.slice";
}
