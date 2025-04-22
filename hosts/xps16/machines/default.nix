{
  imports = [
    ./arch.nix
  ];

  systemd.targets.machines.enable = true;
}
