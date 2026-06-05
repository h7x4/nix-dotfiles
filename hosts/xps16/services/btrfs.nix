{ utils, ... }:
{
  services.btrfs.autoScrub.enable = true;

  systemd.services."btrfs-scrub-${utils.escapeSystemdPath "/"}".serviceConfig = {
    PrivateNetwork = true;
    RestrictFileSystems = [
      "@basic-api" # Needed by both systemd and btrfs (the latter for setting scrub speed in /sys/fs/btrfs)
      "btrfs"
    ];
  };
}
