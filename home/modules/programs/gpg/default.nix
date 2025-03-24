{ ... }:
{
  imports = [
    ./auto-refresh-keys.nix
    ./auto-update-trust-db.nix

    # ./key-fetchers/declarative-github-key-fetcher.nix # WIP
    ./key-fetchers/declarative-keyserver-key-fetcher.nix
  ];
}
