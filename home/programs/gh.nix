{ ... }:
{
  programs.gh = {
    enable = true;
    settings = {
      gitProtocol = "ssh";
      aliases = {
        co = "pr checkout";
        pv = "pr view";
      };
    };
  };
}
