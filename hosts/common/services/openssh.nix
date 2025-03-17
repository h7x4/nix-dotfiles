{ lib, ... }:
{
  services.openssh = {
    enable = lib.mkDefault true;
    startWhenNeeded = true;
    settings = {
      StreamLocalBindUnlink = true;
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
      PermitEmptyPasswords = false;
      ChallengeResponseAuthentication = false;
      GSSAPIAuthentication = false;
      HostbasedAuthentication = false;
      IgnoreRhosts = true;
      KerberosAuthentication = false;
      RhostsRSAAuthentication = false;
      Protocol = "2";
      Macs = [
        "hmac-sha2-512-etm@openssh.com"
        "hmac-sha2-256-etm@openssh.com"
        "umac-128-etm@openssh.com"
        "hmac-sha2-512"
      ];
    };
  };

  # systemd.services."sshd@".serviceConfig = {
  #   Nice = -15;
  #   IOSchedulingClass = "realtime";
  # };
}
