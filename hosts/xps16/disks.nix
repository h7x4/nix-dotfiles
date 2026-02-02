{ lib, ... }:
{
  disko.devices = {
    disk = {
      sda = {
        name = "KXG80ZN84T09 NVMe KIOXIA 4096GB";
        type = "disk";
        device = "/dev/nvme0n1";
        content = {
          type = "gpt";
          partitions = {
            win-efi = {
              uuid = "24d18ca3-d1c0-4fd5-a1f5-c2ef18c3414a";
              name = "EFI system partition";
              label = "ESP";
              start = "2048";
              size = "409600";
            };

            win-reserved = {
              uuid = "7502d3d7-6116-4d9f-afdc-4bb3507a4ae8";
              name = "Microsoft reserved partition";
              start = "411648";
              size = "262144";
            };

            win-os = {
              uuid = "5944d017-36ce-41c9-9b7c-d6b948a3cc3b";
              name = "Basic data partition";
              label = "OS";
              start = "673792";
              size = "1309978624";
            };

            win-retools = {
              uuid = "95b4cc0e-673f-496a-9ec8-425b089fad2e";
              label = "WINRETOOLS";
              start = "7946752000";
              size = "2027520";
              attributes = [
                0 # Required Partition
                63 # Do Not Automount
              ];
            };

            win-image = {
              uuid = "5e187978-7467-4f35-87bf-167cc23b9e43";
              label = "Image";
              start = "7948779520";
              size = "49674240";
              attributes = [
                0 # Required Partition
                63 # Do Not Automount
              ];
            };

            win-dellsupport = {
              uuid = "02f392b7-8a95-48ee-bd4f-2baad5b1595c";
              label = "DELLSUPPORT";
              start = "7998455808";
              size = "3084288";
              attributes = [
                0 # Required Partition
                63 # Do Not Automount
              ];
            };

            # ----------------------------------------- #
            # This is where the interesting part starts #

            boot = {
              uuid = "56cc4363-d1be-4518-8bea-728a4f70464c";
              label = "nixos-boot";
              start = "1310652416";
              size = "2097152";

              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "discard" "umask=0077" ];
              };
            };

            nixos = {
              uuid = "f6995107-19e2-476e-aab4-f414127d7303";
              label = "nixos";
              start = " 1312749568";
              size = "100%";

              content = {
                type = "luks";
                name = "crypted";

                settings = {

                };

                content = {
                  type = "btrfs";
                  extraArgs = [ "-f" ]; # Override existing partition
                  subvolumes = let
                    makeSnapshottable = subvolPath: mountOptions: let
                      name = lib.removePrefix "/" subvolPath;
                    in {
                      "${name}/active" = {
                        mountpoint = subvolPath;
                        inherit mountOptions;
                      };
                      "${name}/snapshots" = {
                        mountpoint = "${subvolPath}/.snapshots";
                        inherit mountOptions;
                      };
                    };

                    # NOTE: everything should've been like this from the start,
                    #       but I did not know what I was doing at the time. Slowly migrating
                    #       over to this format.
                    makeAtSnapshottable = subvolPath: mountOptions: let
                      name = lib.replaceString "/" "-" ( lib.removePrefix "/" subvolPath);
                    in {
                      "@${name}/active" = {
                        mountpoint = subvolPath;
                        inherit mountOptions;
                      };
                      "@${name}/snapshots" = {
                        mountpoint = "${subvolPath}/.snapshots";
                        inherit mountOptions;
                      };
                    };
                  in lib.foldl (x: y: x // y) { } [
                    {
                      "@" = { };
                      "@swap" = {
                        mountpoint = "/.swapvol";
                        mountOptions = [ "compress=zstd" "noatime" ];
                        swap."swapfile".size = "8G";
                      };
                      "root" = {
                        mountpoint = "/";
                        mountOptions = [ "compress=zstd" "noatime" ];
                      };
                    }
                    (makeSnapshottable "/home/h7x4" [ "compress=zstd" "noatime" "nodev" ])
                    (makeSnapshottable "/home/h7x4/git" [ "compress=zstd" "noatime" "nodev" ])
                    (makeAtSnapshottable "/home/h7x4/ctf" [ "compress=zstd" "noatime" "nodev" ])
                    (makeAtSnapshottable "/home/h7x4/downloads" [ "compress=zstd" "noatime" "nosuid" "nodev" ])
                    (makeAtSnapshottable "/home/h7x4/pictures" [ "compress=zstd" "noatime" "noexec" "nosuid" "nodev" ])
                    (makeSnapshottable "/home/h7x4/music" [ "compress=zstd" "noatime" "noexec" "nosuid" "nodev" ])
                    (makeSnapshottable "/var/log" [ "compress=zstd" "noatime" "noexec" "nosuid" "nodev" ])
                    (makeSnapshottable "/var/lib" [ "compress=zstd" "noatime" "nosuid" "nodev" ])
                    (makeAtSnapshottable "/var/lib/docker" [ "compress=zstd" "noatime" ])
                  ];
                };
              };
            };
          };
        };
      };
    };
  };
}
