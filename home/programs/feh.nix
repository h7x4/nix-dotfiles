{ machineVars, ... }:
{
  programs.feh.enable = !machineVars.headless;
}