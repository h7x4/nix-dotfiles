{ pkgs ? import <nixpkgs> {} }: let
  call = pkg: { name = pkg; value = pkgs.callPackage ./${pkg} {}; };
in builtins.listToAttrs (map call [
  # TODO: Add some packages
])
