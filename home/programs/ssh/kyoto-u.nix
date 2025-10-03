{ lib, ... }:
let
  default = {
    user = "oysteikt";
    identityFile = [ "~/.ssh/id_ed25519" ];
  };
in
{
  programs.ssh.matchBlocks = {
    "io" = default // {
      hostname = "io.kuis.kyoto-u.ac.jp";
      # SOCKS proxy for access to internal web.
      dynamicForwards = [{ port = 8080; }];
    };
  } // (lib.genAttrs [
    "argo"
    "procyon"
    "apus"
    "vega"
    "leo"
  ] (name: default // {
    hostname = "${name}.fos.kuis.kyoto-u.ac.jp";
    proxyJump = "io";
  }));
}
