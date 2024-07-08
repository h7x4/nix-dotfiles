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
      identityFile = [ "~/.ssh/id_ed25519" ];
    };
    "github-nordicsemi" = {
      user = "git";
      hostname = "github.com";
      identityFile = [ "~/.ssh/id_ed25519_nordicsemi" ];
    };
    "bitbucket-nordicsemi" = {
      user = "git";
      hostname = "bitbucket.nordicsemi.no";
      port = 7999;
      identityFile = [ "~/.ssh/id_ed25519_nordicsemi" ];
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
