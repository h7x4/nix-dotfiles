{ config, ... }:
{
  services.blueman.enable = config.hardware.bluetooth.enable;
}
