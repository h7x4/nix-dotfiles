{ machineVars, ... }:
{
  programs.obs-studio.enable = !machineVars.headless;
}