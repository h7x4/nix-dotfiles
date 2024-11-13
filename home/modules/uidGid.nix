{ lib, ... }:
{
  options.home = {
    uid = lib.mkOption {
      default = 1000;
      type = lib.types.ints.between 0 60000;
    };
    gid = lib.mkOption {
      default = 1000;
      type = lib.types.ints.between 0 60000;
    };
  };
}