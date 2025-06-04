{ pkgs, ... }:
{
  programs.gh = {
    settings = {
      gitProtocol = "ssh";
      pager = "${pkgs.bat}/bin/bat";
      aliases = {
        co = "pr checkout";
        pv = "pr view";
      };
    };
  };
}
