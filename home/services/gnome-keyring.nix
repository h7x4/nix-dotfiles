{ machineVars, ... }:
{
  services.gnome-keyring.enable = !machineVars.headless;
}