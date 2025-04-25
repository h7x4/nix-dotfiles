{ ... }:
{
  programs.cargo = {
    enable = true;
    settings = {
      cargo-new.vcs = "git";
    };
  };

  home.sessionVariables.CARGO_NET_GIT_FETCH_WITH_CLI = "true";
}
