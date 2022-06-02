{ pkgs, ... }:
{

  programs.adb.enable = true;

  system.extraDependencies = with pkgs; [
    asciidoc
    asciidoctor
    cabal2nix
    clang
    dart
    dotnet-sdk
    dotnet-sdk_3
    dotnet-sdk_5
    dotnetPackages.Nuget
    elm2nix
    elmPackages.elm
    flutter
    gcc
    ghc
    ghcid
    haskellPackages.Cabal_3_6_3_0
    maven
    nixfmt
    nixpkgs-fmt
    # nixpkgs-hammering
    nodePackages.node2nix
    nodePackages.npm
    nodePackages.sass
    nodePackages.typescript
    nodePackages.yarn
    nodejs
    plantuml
    python3
    rustc
    rustc
    rustup
    sqlcheck
    sqlint
    sqlite
    sqlite-web
    xmlformat
    xmlstarlet
  ];
}

