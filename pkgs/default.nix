{ pkgs ? import <nixpkgs> {} }: let
  call = pkg: { name = pkg; value = pkgs.callPackage ./${pkg} {}; };
in builtins.listToAttrs (map call [
  "gitmirror"
  # "koneko"
  # "listen-moe"
  # "bb"
])

# {
#   koneko = pkgs.callPackage ./koneko {};
#   listen-moe = pkgs.callPackage ./listen-moe {};
#   simplicity-studio = pkgs.callPackage ./simplicity-studio-5 {};
#   # deezloader-remix = pkgs.callPackage ./pkgs/deezloader-remix {};
#   ani-cli = pkgs.callPackage ./ani-cli {};
#   bb = pkgs.callPackage ./bb {};
# }
