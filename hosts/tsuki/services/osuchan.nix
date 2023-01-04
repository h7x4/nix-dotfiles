{ secrets, config, ... }:
{
  services.osuchan = {
    enable = true;
    port = secrets.ports.osuchan;
    secretFile = "${config.machineVars.dataDrives.default}/keys/osuchan/envfile";
  };
}
