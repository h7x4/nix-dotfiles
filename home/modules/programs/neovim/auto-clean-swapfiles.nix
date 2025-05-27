{ config, pkgs, lib, ... }:
let
  daysBeforeDeletion = 2;
  cfg = config.programs.neovim.auto-clean-swapfiles;
in
{
  options.programs.neovim.auto-clean-swapfiles = {
    enable = lib.mkEnableOption "automatic cleanup of neovim swapfiles";

    daysBeforeDeletion = lib.mkOption {
      type = lib.types.ints.positive;
      default = 2;
      example = 7;
      description = "How long many days old the swapfile should be before it gets cleaned up";
    };

    onCalendar = lib.mkOption {
      type = lib.types.str;
      default = "daily";
      example = "weekly";
      # TODO: link to systemd manpage for format.
      description = "How often to run the cleanup.";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.user.services.clean-neovim-swap-files = {
      Unit = {
        Description = "Clean old swap files for neovim";
      };

      Service = {
        Type = "oneshot";
        Slice = "background.slice";
        CPUSchedulingPolicy = "idle";
        IOSchedulingClass = "idle";
        ExecStart = lib.getExe (pkgs.writeShellApplication {
          name = "clean-neovim-swap-files";
          runtimeInputs = with pkgs; [ findutils ];
          text = ''
            echo "Cleaning old swap files for neovim"

            OLD_SWAPFILES=$(find "${config.xdg.stateHome}/nvim/swap" -type f -name '*.swp' -mtime +${toString cfg.daysBeforeDeletion})

            if [ -z "$OLD_SWAPFILES" ]; then
              echo "No old swap files found"
              exit 0
            fi

            for swapfile in $OLD_SWAPFILES; do
              echo "Removing $swapfile"
              rm -- "$swapfile" ||  echo "Could not remove $swapfile, is it still in use?"
            done

            echo "Done"
          '';
        });
      };
    };

    systemd.user.timers.clean-neovim-swap-files = {
      Unit = {
        Description = "Clean old swap files for neovim";
      };

      Timer = {
        Unit = "clean-neovim-swap-files.service";
        OnCalendar = cfg.onCalendar;
        Persistent = true;
      };

      Install = {
        WantedBy = [ "timers.target" ];
      };
    };
  };
}
