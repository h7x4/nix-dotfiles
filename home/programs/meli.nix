{ pkgs, ... }:
{
  programs.meli = {
    package = pkgs.meli.overrideAttrs {
      doCheck = false;
    };
  };
}
