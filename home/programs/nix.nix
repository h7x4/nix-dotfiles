{ config, lib, ... }:
{
  sops = {
    secrets = {
      "nix/access-tokens/github" = { sopsFile = ./../../secrets/common.yaml; };
      "nix/access-tokens/pvv-git" = { sopsFile = ./../../secrets/common.yaml; };
    };
    templates."nix-access-tokens.conf".content = let
      inherit (config.sops) placeholder;

      tokens = {
        "github.com" = placeholder."nix/access-tokens/github";
        "git.pvv.ntnu.no" = placeholder."nix/access-tokens/pvv-git";
      };
    in "access-tokens = ${lib.pipe tokens [
      lib.attrsToList
      (builtins.sort (p: q: p.name > q.name))
      (map ({ name, value }: "${name}=${value}"))
      (builtins.concatStringsSep " ")
    ]}";
  };

  nix = {
    settings.use-xdg-base-directories = true;
    extraOptions = ''
      !include ${config.sops.templates."nix-access-tokens.conf".path}
    '';
  };
}
