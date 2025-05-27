{ config, pkgs, lib, ... }:
let
  cfg = config.wayland.windowManager.hyprland;
in
{
  config = lib.mkIf cfg.enable {
    wayland.windowManager.hyprland.settings = let
      exe = lib.getExe;
      scratchpads = [
        (rec {
          title = "Floating terminal";
          class = "floatingTerminal";
          command = "uwsm app -- ${exe pkgs.alacritty} --class ${class} -e ${exe pkgs.tmux} new-session -A -s f";
          size = { h = 90; w = 95; };
          keys = [
            "$mod, RETURN"
            "$mod, SPACE"
          ];
        })
        (rec {
          title = "Ncmpcpp";
          class = "floatingNcmpcpp";
          command = "uwsm app -- ${exe pkgs.alacritty} --class ${class} -e ${exe pkgs.ncmpcpp}";
          size = { h = 95; w = 95; };
          keys = [ "$mod, Q" ];
        })
        # "$mod, W, emacs"
        # "$mod, E, filebrowser"
        # "$mod, X, taskwarriortui"
      ];
    in {
      bind = lib.pipe scratchpads [
        (map ({ keys, command, class, ... }:
          (map (key: let
            # TODO: rewrite this to take arguments instead of creating n copies
            invokeIfNotRunningAndToggleWorkspace = pkgs.writeShellApplication {
              name = "hyprland-toggle-scratchpad-${class}";
              runtimeInputs = [ cfg.finalPackage pkgs.jq ];
              text = ''
                SCRATCHPAD_PROGRAM_EXISTS=$(hyprctl clients -j | jq -r '[.[].class]|any(. == "${class}")')
                CURRENT_WORKSPACE_ID=$(hyprctl activeworkspace -j | jq -r '.id')

                if [ "$SCRATCHPAD_PROGRAM_EXISTS" != "true" ]; then
                  ${command} &
                  hyprctl dispatch movetoworkspacesilent "''${CURRENT_WORKSPACE_ID},class:${class}"
                  hyprctl dispatch focuswindow "class:${class}"
                else
                  SCRATCHPAD_PROGRAM_WORKSPACE_ID=$(hyprctl clients -j | jq '.[] | select( .class == "${class}") | .workspace.id')
                  if [ "$SCRATCHPAD_PROGRAM_WORKSPACE_ID" != "$CURRENT_WORKSPACE_ID" ]; then
                    hyprctl dispatch movetoworkspacesilent "''${CURRENT_WORKSPACE_ID},class:${class}"
                    hyprctl dispatch focuswindow "class:${class}"
                  else
                    hyprctl dispatch movetoworkspacesilent "special:${class}Ws,class:${class}"
                  fi
                fi
              '';
            };
          in "${key}, exec, ${lib.getExe invokeIfNotRunningAndToggleWorkspace}"
          ) keys)
        ))
        lib.flatten
      ];

      windowrulev2 = lib.pipe scratchpads [
        (map ({ class, size, ... }: [
          "workspace special:${class}Ws, class:^(${class})$"
          "float, class:^${class}$"
          "size ${toString size.w}% ${toString size.h}%, class:^(${class})$"
          "move ${toString ((100 - size.w) / 2)}% ${toString ((100 - size.h) / 2)}%, class:^(${class})$"
        ]))
        lib.flatten
      ];
    };
  };
}
