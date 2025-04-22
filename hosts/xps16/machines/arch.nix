{ ... }:
{
  systemd.nspawn."arch" = {
    enable = true;
    execConfig.Boot = true;

    filesConfig = {
      BindReadOnly = [
        "/nix/store"
        # "/etc/resolv.conf:/etc/resolv.conf"
      ];
      Bind = [
        "/home/h7x4/git"
        "/home/h7x4/Downloads"
      ];
    };
    networkConfig.Private = false;
  };

  systemd.services."systemd-nspawn@arch" = {
    enable = true;
    requiredBy = [ "machines.target" ];
    overrideStrategy = "asDropin";
  };
}
