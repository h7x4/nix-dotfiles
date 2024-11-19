{ machineVars, ... }:
{
  programs.mpv.enable = !machineVars.headless;
}