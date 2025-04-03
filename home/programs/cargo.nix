{ ... }:
{
  programs.cargo = {
    enable = true;
    settings = {
      cargo-new.vcs = "git";
    };
  };
}
