{ config, pkgs, lib, ... }:
let
  cfg = config.programs.nix-index.autoUpdateDatabase;
in
{
  options.programs.nix-index.autoUpdateDatabase = {
    enable = lib.mkEnableOption "timed unit that fetches an updated database of nixpkgs outputs";

    # TODO: let users specify forks and other sources
    # url = "";

    onCalendar = lib.mkOption {
      type = lib.types.str;
      default = "weekly";
      example = "montly";
      # TODO: link to systemd manpage for format.
      description = "How often to update the database.";
    };
  };

  config = {
    systemd.user.timers.fetch-nix-index-database = lib.mkIf cfg.enable {
      Unit = {
        Description = "Fetch nix-index database";
        Documentation = [ "https://github.com/nix-community/nix-index-database" ];
      };

      Timer = {
        Unit = "fetch-nix-index-database.service";
        OnCalendar = cfg.onCalendar;
        Persistent = true;
      };

      Install = {
        WantedBy = [ "timers.target" ];
      };
    };

    systemd.user.services.fetch-nix-index-database = lib.mkIf cfg.enable {
      Unit = {
        Description = "Fetch nix-index database";
        Documentation = [ "https://github.com/nix-community/nix-index-database" ];
      };

      Service = {
        Type = "oneshot";
        ExecStart = lib.getExe (pkgs.writeShellApplication {
          name = "fetch-nix-index-database";
          runtimeInputs = with pkgs; [
            coreutils
            gnused
            wget
          ];

          # TODO: allow fetching with gh + github token

          # Source: https://github.com/nix-community/nix-index-database?tab=readme-ov-file#ad-hoc-download
          # Slightly modified to satisfy shellcheck
          text = ''
            download_nixpkgs_cache_index () {
              filename="index-$(uname -m | sed 's/^arm64$/aarch64/')-$(uname | tr '[:upper:]' '[:lower:]')"
              mkdir -p "${config.home.homeDirectory}/.cache/nix-index" && cd "${config.home.homeDirectory}/.cache/nix-index"
              # -N will only download a new version if there is an update.
              wget -q -N "https://github.com/nix-community/nix-index-database/releases/latest/download/$filename"
              ln -f "$filename" files
            }

            download_nixpkgs_cache_index
          '';
        });
      };
    };
  };
}
