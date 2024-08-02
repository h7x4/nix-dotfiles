{ ... }:
{
  imports = [ ./fetch-nix-index-database.nix ];

  programs.nix-index = {
    enable = true;
    enableDatabaseFetcher = true;
  };
}