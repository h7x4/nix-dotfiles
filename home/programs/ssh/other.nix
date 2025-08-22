{ lib, ... }:
{
  programs.ssh.matchBlocks = {
    "ntnu" = {
      user = "oysteikt";
      hostname = "login.stud.ntnu.no";
      proxyJump = "pvv";
    };
    "github" = {
      user = "git";
      hostname = "github.com";
      identityFile = [ "~/.ssh/id_rsa" ];
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
    "garp" = {
      user = "h7x4";
      hostname = "garp.pbsds.net";
      proxyJump = "pvv";
    };
    "bolle" = {
      user = "h7x4";
      hostname = "bolle.pbsds.net";
      proxyJump = "pvv";
    };
  };
}
