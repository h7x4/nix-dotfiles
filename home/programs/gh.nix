{ pkgs, ... }:
{
  programs.gh = {
    enable = true;
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
