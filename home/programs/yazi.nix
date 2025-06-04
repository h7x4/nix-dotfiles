{ ... }:
{
  programs.yazi = {
    keymap = {
      manager.prepend_keymap = [
        {
          run = "quit --no-cwd-file";
          on = [ "<Esc>" ];
          desc = "Quit without outputting cwd-file";
        }
      ];
      pick.prepend_keymap = [
        {
          run = "close";
          on = [ "<Esc>" ];
          desc = "Quit without submitting the picker";
        }
      ];
    };
  };
}
