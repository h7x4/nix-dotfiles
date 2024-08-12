{ config, ... }:
{
  services.printing.enable = !config.machineVars.headless;
}
