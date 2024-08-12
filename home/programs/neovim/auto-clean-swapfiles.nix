{ config, pkgs, lib, ... }:
let
  daysBeforeDeletion = 2;
in
{
  config = {
    systemd.user.services.clean-neovim-swap-files = {
      Unit = {
        Description = "Clean old swap files for neovim";
      };

      Service = {
        Type = "oneshot";
        CPUSchedulingPolicy = "idle";
        IOSchedulingClass = "idle";
        ExecStart = lib.getExe (pkgs.writeShellApplication {
          name = "clean-neovim-swap-files";
          runtimeInputs = with pkgs; [ findutils ];
          text = ''
            echo "Cleaning old swap files for neovim"

            OLD_SWAPFILES=$(find "${config.xdg.stateHome}/nvim/swap" -type f -name '*.swp' -mtime +${toString daysBeforeDeletion})

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
        OnCalendar = "daily";
        Persistent = true;
      };

      Install = {
        WantedBy = [ "timers.target" ];
      };
    };
  };
}
