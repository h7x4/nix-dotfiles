{ config, lib, ... }:
let
  cfg = config.programs.bottom;
in
{
  programs.bottom = {
    settings = {
      flags.enable_gpu = true;

      row = [
        {
          ratio = 30;
          child = [{ type = "cpu"; }];
        }
        {
          ratio = 40;
          child = [
            {
              ratio = 4;
              type = "mem";
            }
            {
              ratio = 3;
              type = "disk";
            }
          ];
        }
        {
          ratio = 30;
          child = [
            {
              type = "net";
            }
            {
              default = true;
              type = "proc";
            }
          ];
        }
      ];
    };
  };
}
