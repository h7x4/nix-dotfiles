{ lib, ... }:
{
  programs.ssh.matchBlocks = {
    "pascal wack" = {
      user = "h7x4";
      hostname = "wiki.wackattack.eu";
      port = 1337;
    };
  };
}
