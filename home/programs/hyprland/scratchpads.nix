{ config, pkgs, lib, ... }: let
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
            (lib.generators.mkLuaInline "mod .. \" + RETURN\"")
            (lib.generators.mkLuaInline "mod .. \" + SPACE\"")
          ];
        })
        (rec {
          title = "Ncmpcpp";
          class = "floatingNcmpcpp";
          command = "uwsm app -- ${exe pkgs.alacritty} --class ${class} -e ${exe pkgs.ncmpcpp}";
          size = { h = 90; w = 95; };
          keys = [
            (lib.generators.mkLuaInline "mod .. \" + Q\"")
          ];
        })
        # "$mod, W, emacs"
        # "$mod, E, filebrowser"
        # "$mod, X, taskwarriortui"
      ];
    in {
      scratchpads._var = scratchpads;

      fixScratchpad._var = lib.generators.mkLuaInline ''
        function(scratchpad, window, monitor_)
          local monitor = monitor_
          if monitor == nil then
            monitor = window.monitor
          end

          local scaled_w = monitor.width * (1/monitor.scale)
          local scaled_h = monitor.height * (1/monitor.scale)

          -- I have no idea why these need to be run twice, but despite the values being the same,
          -- it somehow always misplaces the window the first time around...
          hl.dispatch(hl.dsp.window.move({
            x = monitor.x + (scaled_w * (((100 -scratchpad.size.w) / 2) / 100)),
            y = monitor.y + (scaled_h * (((100 -scratchpad.size.h) / 2) / 100)),
            relative = false
          }))
          hl.dispatch(hl.dsp.window.resize({
            x = scaled_w * scratchpad.size.w / 100,
            y = scaled_h * scratchpad.size.h / 100,
            relative = false
          }))
          hl.dispatch(hl.dsp.window.move({
            x = monitor.x + (scaled_w * (((100 -scratchpad.size.w) / 2) / 100)),
            y = monitor.y + (scaled_h * (((100 -scratchpad.size.h) / 2) / 100)),
            relative = false
          }))
          hl.dispatch(hl.dsp.window.resize({
            x = scaled_w * scratchpad.size.w / 100,
            y = scaled_h * scratchpad.size.h / 100,
            relative = false
          }))
        end
      '';

      invokeScratchpad._var = lib.generators.mkLuaInline ''
        function(scratchpad)
          local scratchpad_window = hl.get_window("class:^(" .. scratchpad.class .. ")$")
          local current_workspace = hl.get_active_workspace()

          if scratchpad_window == nil then
            hl.dispatch(hl.dsp.exec_cmd(scratchpad.command, {
              workspace = current_workspace.id
            }))
          else
            hl.dispatch(hl.dsp.focus({ window = scratchpad_window }))

            if scratchpad_window.workspace.id ~= current_workspace.id then
              hl.dispatch(hl.dsp.window.move({ workspace = current_workspace.id }))
              fixScratchpad(scratchpad, scratchpad_window, current_workspace.monitor)
            else
              hl.dispatch(hl.dsp.window.move({ workspace = "special:" .. scratchpad.class .. "Ws", follow = false }))
            end
          end
        end
      '';

      bind = lib.concatLists (lib.imap1 (i: { keys, command, class, size, ... }: map (key: {
        _args = [
          key
          (lib.generators.mkLuaInline "function() invokeScratchpad(scratchpads[${toString i}]) end")
        ];
      }) keys) scratchpads);

      window_rule = map ({ class, size, ... }: {
        name = "scratchpad_${class}";
        match.class = "^(${class})$";

        float = true;
        size = [
          "(monitor_w*${toString (size.w / 100.0)})"
          "(monitor_h*${toString (size.h / 100.0)})"
        ];
        move = [
          "(monitor_w*${toString (((100 - size.w) / 2) / 100.0)})"
          "(monitor_h*${toString (((100 - size.h) / 2) / 100.0)})"
        ];
      }) scratchpads;

      # TODO: fix me
      on._args = [
        "workspace.move_to_monitor"
        (lib.mkLuaInline ''
          function(workspace, monitor)
            for _, scratchpad in pairs(scratchpads) do
              local scratchpad_window = hl.get_window("class:^(" .. scratchpad.class .. ")$")
              if scratchpad_window == nil or scratchpad_window.workspace.id ~= workspace.id then
                -- NOTE: crazy that there's no continue in lua...
                goto continue
              end

              -- hl.notification.create({
              --   time = 3000,
              --   text = "Fixing scratchpad " .. scratchpad.class .. " to monitor " .. monitor.name
              -- })

              fixScratchpad(scratchpad, scratchpad_window, monitor)

              ::continue::
            end
          end
        '')
      ];
    };
  };
}
