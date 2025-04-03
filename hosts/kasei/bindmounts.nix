{ ... }:
{
  systemd.mounts = let
    mkBindmount = name: src: dst: {
      description = "Bindmount for ${name}";
      what = src;
      where = dst;
      type = "none";
      options = "bind";
      before = [ "local-fs.target" ];
      wantedBy = [ "local-fs.target" ];
    };
  in [
    (mkBindmount ".local" "/data/local" "/home/h7x4/.local")
    (mkBindmount "Downloads" "/data/Downloads" "/home/h7x4/Downloads")
    (mkBindmount "Dropbox" "/data/Dropbox" "/home/h7x4/Dropbox")
    (mkBindmount "MEGA" "/data/MEGA" "/home/h7x4/MEGA")
    (mkBindmount "NTNU" "/data/pCloud/NTNU" "/home/h7x4/NTNU")
    (mkBindmount "ctf" "/data/ctf" "/home/h7x4/ctf")
    (mkBindmount "documents" "/data/pCloud/documents" "/home/h7x4/documents")
    (mkBindmount "downloads" "/data/Downloads" "/home/h7x4/downloads")
    (mkBindmount "git" "/data/git" "/home/h7x4/git")
    (mkBindmount "music" "/data/pCloud" "/home/h7x4/music")
    (mkBindmount "nixpkgs" "/data/nixpkgs" "/home/h7x4/nixpkgs")
    (mkBindmount "pictures" "/data/pCloud/pictures" "/home/h7x4/pictures")
    (mkBindmount "pvv" "/data/pvv" "/home/h7x4/pvv")
    (mkBindmount "Zotero" "/data/Zotero" "/home/h7x4/Zotero")
  ];
}
