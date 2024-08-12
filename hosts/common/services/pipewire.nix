{ config, ... }:
{
  services.pipewire = {
    enable = !config.machineVars.headless;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
}
