{ utils, ... }:
{
  services.btrfs.autoScrub.enable = true;

  systemd.services."btrfs-scrub-${utils.escapeSystemdPath "/"}".serviceConfig = {
    PrivateNetwork = true;
    RestrictFileSystems = [
      "sysfs" # Needed to set scrub speed in /sys/fs/btrfs
      "btrfs"
    ];
  };
}
