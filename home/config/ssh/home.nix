{ ... }:
{
  programs.ssh.matchBlocks = {
    suiseir = {
      user = "h7x4";
      hostname = "heimen.hopto.me";
      port = 23934;
    };
    pir = {
      user = "h7x4";
      hostname = "gingakei.loginto.me";
      port = 41348;
    };
    tsukir = {
      user = "h7x4";
      hostname = "gingakei.loginto.me";
      port = 45497;
    };
    "git.nani.wtf git.tsuki.local git.seiun.cloud" = {
      user = "git";
      hostname = "gingakei.loginto.me";
      port = 45497;
    };
  };
}
