{ ... }:
{
  disko.devices = {
    disk = {
      nvme1 = {
        type = "disk";
        device = "/dev/nvme0n1";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              content = {
                format = "vfat";
                mountpoint = "/boot";
                type = "filesystem";
              };
              name = "boot";
              size = "1G";
              type = "EF00";
            };

            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "zroot";
              };
            };
          };
        };
      };
      nvme2 = {
        type = "disk";
        device = "/dev/nvme1n1";
        content = {
          type = "gpt";
          partitions = {
            # No boot partition here

            zfs = {
              start = "1G";
              size = "100%";
              content = {
                type = "zfs";
                pool = "zroot";
              };
            };
          };
        };
      };
    };
    zpool = {
      zroot = {
        type = "zpool";
        mode = {
          topology = {
            type = "topology";
            vdev = [
              {
                mode = "mirror";
                members = [ "nvme1" "nvme2" ];
              }
            ];
          };
        };

        options = {
          ashift = "12";

          # trim handled by systemd timer
          autotrim = "off";
        };
        rootFsOptions = {
          acltype = "posixacl";
          canmount = "off";
          compression = "zstd";
          dedup = "on";
          devices = "off";
          dnodesize = "auto";
          mountpoint = "none";
          normalization = "formD";
          relatime = "on";
          xattr = "sa";

          encryption = "aes-256-gcm";
          keyformat = "passphrase";
          keylocation = "prompt";
        };

        postCreateHook = ''
          zfs set keylocation=prompt zroot;
        '';

        datasets = let
          root = "nixos";
          legacyMount = mountpoint: {
            type = "zfs_fs";
            options.mountpoint = "legacy";
            inherit mountpoint;
          };
        in {
          "${root}" = {
            type = "zfs_fs";
            options.mountpoint = "none";
          };

          "${root}/root" = legacyMount "/";

          "${root}/nix" = legacyMount "/nix";

          "${root}/var" = legacyMount "/var";
          "${root}/var/cache" = legacyMount "/var/cache";
          "${root}/var/log" = legacyMount "/var/log";

          "${root}/var/lib" = legacyMount "/var/lib";
          "${root}/var/lib/containers/storage" = legacyMount "/var/lib/containers/storage";
          "${root}/var/lib/containers/storage/volumes" = legacyMount "/var/lib/containers/storage/volumes";
          "${root}/var/lib/postgresql" = (legacyMount "/var/lib/postgresql") // {
            options = {
              mountpoint = "legacy";
              recordsize = "16k";
              primarycache = "all";
            };
          };

          "${root}/home" = legacyMount "/home";

          "${root}/data" = legacyMount "/data";
          "${root}/data/minecraft" = legacyMount "/data/minecraft";
          "${root}/data/backup" = (legacyMount "/data/backup") // {
            options = {
              mountpoint = "legacy";
              compression = "zstd-15";
            };
	  };

          "${root}/data/media" = (legacyMount "/data/media") // {
            options = {
              mountpoint = "legacy";
              recordsize = "512k";
            };
          };

          "reserved" = {
            type = "zfs_fs";
            options = {
              mountpoint = "none";
              refreservation = "10G";
            };
          };
        };
      };
    };
  };
}
