{ ... }: let
  nfsDrive = drivename: {
    device = "10.0.0.36:/mnt/PoolsClosed/${drivename}";
    fsType = "nfs";
    options = [ "nfsvers=3" ];
  };
in {
  fileSystems."/data2/backup" = nfsDrive "backup";
  fileSystems."/data2/momiji" = nfsDrive "momiji";
  fileSystems."/data2/media" = nfsDrive "media";
  fileSystems."/data2/postgres" = nfsDrive "postgres";
  fileSystems."/data2/home" = nfsDrive "home";
}
