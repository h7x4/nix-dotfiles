{ config, lib, ... }:
let
  cfg = config.programs.cargo;
in
lib.mkIf cfg.enable {
  programs.cargo = {
    settings = {
      cargo-new.vcs = "git";
    };
  };

  home.sessionVariables.CARGO_NET_GIT_FETCH_WITH_CLI = "true";
}
