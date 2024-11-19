{ machineVars, ... }:
{
  services.network-manager-applet.enable = !machineVars.headless;
}