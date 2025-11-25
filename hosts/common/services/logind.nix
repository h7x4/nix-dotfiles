{ ... }:
{
  services.logind = {
    settings.Login.HandlePowerKeyLongPress = "poweroff";
  };
}
