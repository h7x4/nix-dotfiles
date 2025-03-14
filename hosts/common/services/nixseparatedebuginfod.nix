{ config, ... }: {
  services.nixseparatedebuginfod = {
    enable = true;
    nixPackage = config.nix.package;
  };
}
