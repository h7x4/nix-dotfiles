{ ... }:
{
  services.tlp = {
    enable = true;
    settings = {
      RUNTIME_PM_ON_AC = "auto";
      RUNTIME_PM_ON_BAT = "auto";
      USB_AUTOSUSPEND = "0";
    };
  };
}
