{ config, ... }:
{
  services.pipewire = {
    enable = !config.machineVars.headless;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;

    wireplumber = {
      enable = true;

      extraConfig."10-bluez" = {
        "monitor.bluez.properties" = {
          "bluez5.enable-sbc-xq" = true;
          "bluez5.enable-msbc" = true;
          "bluez5.enable-hw-volume" = true;
          "bluez5.codecs" = [
            "ldac"
            "aac"
            "sbc_xq"
            "aptx"
            "sbc"
          ];
        };
      };
    };
  };
}
