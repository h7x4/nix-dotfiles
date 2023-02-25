{ secrets, config, ... }:
{
  services.osuchan = {
    enable = true;
    port = secrets.ports.osuchan;
    secretFile = "${config.machineVars.dataDrives.default}/keys/osuchan/envfile";

  };

  systemd.services.osuchan.after = [
    "data2-momiji.mount"
  ];
}
