{ config, ...}:
{
  services.libinput = {
    enable = !config.machineVars.headless;
    touchpad.disableWhileTyping = true;
  };
}