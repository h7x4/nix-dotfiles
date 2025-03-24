{ config, pkgs, lib, ... }:
let
  cfg = config.programs.gpg;
in
{
  # TODO: Create proper descriptions
  options = {
    programs.gpg.key-fetchers.github = {
      enable = lib.mkEnableOption "auto fetching of gpg keys by github username";

      useGh = lib.mkEnableOption "" // {
        description = "Whether to use the GitHub API through the gh tools to fetch GPG keys";
        default = config.programs.gh.enable;
        defaultText = lib.literalExpression "config.programs.gh.enable";
      };

      keys = lib.mkOption {
        description = "";
        default = { };
        type = lib.types.attrsOf (lib.types.submodule ({ name, ... }: {
          options = {
            # id = lib.mkOption {
            #   description = "";
            #   default = name;
            #   example = "";
            #   type = lib.types.str;
            # };

            username = lib.mkOption {
              description = "";
              default = name;
              type = lib.types.nonEmptyStr;
            };

            trust = lib.mkOption {
              description = "If marked as null, it's mutable";
              default = null;
              example = 4;
              type = with lib.types; nullOr (ints.between 1 5);
            };
          };
        }));
      };
    };
  };

  config = lib.mkIf cfg.key-fetchers.github.enable {
    systemd.user.services."gpg-fetch-github-key@" = {
      description = "Fetch GPG keys for GitHub user %i";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        CPUSchedulingPolicy = "idle";
        IOSchedulingClass = "idle";

        # TODO: warn if user or key does not exist
        ExecStart = let
          ghScript = pkgs.writeShellApplication {
            name = "fetch-github-gpg-keys";
            runtimeInputs = [
              config.programs.gh.package
              pkgs.jq
              cfg.package
            ];
            text = ''
              gh api users/''${1}/gpg_keys | jq -r '.[].raw_key' | gpg --import
            '';
          };

          curlScript = pkgs.writeShellApplication {
            name = "fetch-github-gpg-keys";
            runtimeInputs = [
              pkgs.curl
              pkgs.jq
              cfg.package
            ];
            text = ''
              curl -s https://api.github.com/users/''${1}/gpg_keys | jq -r '.[].raw_key' | gpg --import
            '';
          };
        in if cfg.key-fetchers.github.useGh then ghScript else curlScript;

        Restart = "on-failure";
        RestartSec = "10s";
        Environment = [
          "GNUPGHOME=${cfg.homedir}"
        ];
      };
    };

    # systemd.user.timers =
  };
}
