{ config, ... }:
{
  sops = {
    secrets = {
      "nix/access-tokens/github" = { sopsFile = ../../secrets/common.yaml; };
      "nix/access-tokens/pvv-git" = { sopsFile = ../../secrets/common.yaml; };
    };
    templates."nix-access-tokens.conf".content = let
      inherit (config.sops) placeholder;
    in ''
      access-tokens = github.com=${placeholder."nix/access-tokens/github"} git.pvv.ntnu.no=${placeholder."nix/access-tokens/pvv-git"}
    '';
  };

  nix = {
    settings.use-xdg-base-directories = true;
    extraOptions = ''
      !include ${config.sops.templates."nix-access-tokens.conf".path}
    '';
  };
}
