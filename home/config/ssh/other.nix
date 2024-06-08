{ lib, ... }:
{
  programs.ssh.matchBlocks = {
    "ntnu" = {
      user = "oysteikt";
      hostname = "login.stud.ntnu.no";
      proxyJump = "pvv";
    };
    "gitlab.stud.idi.ntnu.no" = {
      user = "git";
      proxyJump = "pvv";
    };
    "pascal wack" = {
      user = "h7x4";
      hostname = "wiki.wackattack.eu";
      port = 1337;
    };
  };
}
