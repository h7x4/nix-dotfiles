{ config, unstable-pkgs, ... }:
{
  imports = [
    ./nix-builders/bob.nix
    ./nix-builders/isvegg.nix
    ./nix-builders/tsuki.nix
  ];

  sops.secrets = {
    "nix/access-tokens" = { sopsFile = ./../../secrets/common.yaml; };
  };

  nix = {
    package = unstable-pkgs.nixVersions.stable;
    distributedBuilds = config.networking.hostName != "tsuki";

    settings = {
      allow-dirty = true;
      allowed-uris = [ "http://" "https://" ];
      auto-optimise-store = true;
      binary-caches = [ "https://cache.nixos.org/" ];
      builders-use-substitutes = true;
      experimental-features = [ "nix-command" "flakes" ];
      log-lines = 50;
      trusted-users = [ "h7x4" "nix-builder" ];
      use-xdg-base-directories = true;
    };

    extraOptions = ''
      !include ${config.sops.secrets."nix/access-tokens".path}
    '';

    registry = {
      home.to = {
        type = "path";
        path = "/home/h7x4/nix";
      };
      wack.to = {
        type = "path";
        path = "/home/h7x4/git/wack-ctf-flake";
      };
      nxpt.to = {
        type = "path";
        path = "/home/h7x4/git/nixpkgs-tools";
      };
    };
  };
}
