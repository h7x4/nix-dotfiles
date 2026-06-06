{ config, pkgs, lib, ... }:
let
  cfg = config.programs.git.maintenance.repository-detector;
in
{
  options.programs.git.maintenance.repository-detector = {
    enable = lib.mkEnableOption "automatic detection of git repositories to run maintenace tasks on";

    directories = lib.mkOption {
      type = lib.types.listOf lib.types.path;
      default = [ ];
      example = lib.literalExpression ''
        [
          "''${config.home.homeDirectory}/Projects"
        ]
      '';
      description = "Directories to search for git repositories to run maintenance tasks on.";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = config.programs.git.maintenance.enable;
        message = "programs.git.maintenance.repository-detector.enable requires programs.git.maintenance.enable to work";
      }
      # TODO: merge the predefined repositories with the ones discovered by the repository detector.
      {
        assertion = config.programs.git.maintenance.repositories == [ ];
        message = "programs.git.maintenance.repository-detector.enable will override any manually configured repositories";
      }
    ];

    systemd.user.services."git-maintenance@".Service = {
      RuntimeDirectory = "git-maintenance@%i";

      ExecStartPre = let
        script = pkgs.writeShellApplication {
          name = "discover-git-maintenance-repos";
          runtimeInputs = [ config.programs.git.package pkgs.coreutils ];
          text = ''
            echo "[maintenance]" > "$1"

            shopt -s nullglob
            for repoLocation in ${lib.escapeShellArgs cfg.directories}; do
              for repo in "$repoLocation"/*/.git; do
                if [ -f "$repo/config" ] && [ "$(git config get -f "$repo/config" maintenance.skip)" == true ]; then
                  echo "Skipping $repo because maintenance.skip is set to true" >&2
                else
                  echo "Found git repository at $repo" >&2
                  echo "repo = $(realpath "''${repo%"/.git"}")" >> "$1"
                fi
              done
            done
          '';
        };
      in "${lib.getExe script} '%t/git-maintenance@%i/repos.conf'";

      ExecStart = lib.mkForce ''
        "${lib.getExe config.programs.git.package}" -c include.path="%t/git-maintenance@%i/repos.conf" for-each-repo --keep-going --config=maintenance.repo maintenance run --schedule=%i
      '';
    };
  };
}
