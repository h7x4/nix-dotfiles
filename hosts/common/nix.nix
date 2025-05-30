{ config, lib, unstable-pkgs, ... }:
{
  imports = [
    ./nix-builders/bob.nix
    ./nix-builders/isvegg.nix
    ./nix-builders/tsuki.nix
  ];

  sops = {
    secrets = {
      "nix/access-tokens/github" = { sopsFile = ./../../secrets/common.yaml; };

      "nix/access-tokens/pvv-git" = { sopsFile = ./../../secrets/common.yaml; };

      "nix/access-tokens/github-nordicsemi" = { sopsFile = ./../../secrets/common.yaml; };
      "nix/access-tokens/bitbucket-nordicsemi" = { sopsFile = ./../../secrets/common.yaml; };
    };
    templates."nix-access-tokens.conf".content = let
      inherit (config.sops) placeholder;

      tokens = {
        "github.com" = placeholder."nix/access-tokens/github";

        "git.pvv.ntnu.no" = placeholder."nix/access-tokens/pvv-git";

        "bitbucket.nordicsemi.no" = placeholder."nix/access-tokens/bitbucket-nordicsemi";
        "github.com/NordicPlayground" = placeholder."nix/access-tokens/github-nordicsemi";
        "github.com/NordicSemiconductor" = placeholder."nix/access-tokens/github-nordicsemi";
      };
    in "access-tokens = ${lib.pipe tokens [
      lib.attrsToList
      (builtins.sort (p: q: p.name > q.name))
      (map ({ name, value }: "${name}=${value}"))
      (builtins.concatStringsSep " ")
    ]}";
  };

  nix = {
    package = unstable-pkgs.nixVersions.latest;
    distributedBuilds = config.networking.hostName != "tsuki";

    daemonCPUSchedPolicy = "batch";

    settings = {
      allow-dirty = true;
      allowed-uris = [ "http://" "https://" ];
      binary-caches = [ "https://cache.nixos.org/" ];
      builders-use-substitutes = true;
      experimental-features = [ "nix-command" "flakes" ];
      log-lines = 50;
      trusted-users = [ "h7x4" ];
      allowed-users = [ "@users" ];
      use-xdg-base-directories = true;
    };

    extraOptions = ''
      !include ${config.sops.templates."nix-access-tokens.conf".path}
    '';

    optimise.automatic = true;
    gc.automatic = true;

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
      shells.to = {
        type = "git";
        url = "https://git.pvv.ntnu.no/oysteikt/shells.git";
        ref = "main";
      };
    };
  };
}
