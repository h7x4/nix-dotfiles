{ ... }:
{
  services.openssh = {
    startWhenNeeded = true;
    settings = {
      StreamLocalBindUnlink = true;
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
    };
  };
}
