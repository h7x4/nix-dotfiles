{ pkgs, ... }:
{
  programs.gh = {
    enable = true;
    settings = {
      gitProtocol = "ssh";
      pager = "${pkgs.bat}/git/bat";
      aliases = {
        co = "pr checkout";
        pv = "pr view";
      };
    };
  };
}
