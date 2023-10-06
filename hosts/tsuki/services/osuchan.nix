{ secrets, config, ... }:
{
  services.osuchan = {
    enable = true;
    port = 9283;
    secretFile = "${config.machineVars.dataDrives.default}/keys/osuchan/envfile";
  };

  systemd.services.osuchan.after = [
    "data2-momiji.mount"
  ];
}
