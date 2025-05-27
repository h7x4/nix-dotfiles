{ config, lib, ... }:
let
  cfg = config.services.downloads-sorter;
in
{
  services.downloads-sorter = {
    enable = true;
    mappings = {
      "archives" = [
        "*.rar"
        "*.zip"
        "*.7z"
        "*.tar"

        "*.tar.bz2"
        "*.tar.gz"
        "*.tar.lz4"
        "*.tar.lzma"
        "*.tar.sz"
        "*.tar.sz"
        "*.tar.xz"
        "*.tar.zst"

        "*.tbz"
        "*.tbz2"
        "*.tgz"
        "*.tlz4"
        "*.tlzma"
        "*.tsz"
        "*.txz"
        "*.tzst"

        "*.bz2"
        "*.gz"
        "*.lz4"
        "*.lzma"
        "*.sz"
        "*.sz"
        "*.xz"
        "*.zst"
      ];

      "pictures" = {
        createDirIfNotExists = false;
        globs = [
          "*.gif"
          "*.jpeg"
          "*.jpg"
          "*.png"
          "*.svg"
          "*.webp"
        ];
      };

      "docs" = {
        createDirIfNotExists = false;
        globs = [
          "*.md"

          "*.pdf"
          "*.PDF" # why do people do this

          "*.docx"
          "*.doc"

          "*.xlsx"
          "*.xls"

          "*.ppt"
          "*.pptx"

          "*.odt"
          "*.ods"
          "*.odp"
          "*.odg"
          "*.odf"
        ];
      };

      "books" = {
        createDirIfNotExists = false;
        globs = [ "*.epub" ];
      };

      "videos" = {
        createDirIfNotExists = false;
        globs = [
          "*.mp4"
          "*.webm"
          "*.mov"
        ];
      };

      "isos" = [
        "*.iso"
        "*.img"
      ];
      "jars" = [ "*.jar" ];
      "txt" = [ "*.txt" ];
      "patches" = [
        "*.patch"
        "*.diff"
      ];
    };
  };

  systemd.user.tmpfiles.settings."10-downloads-sorter-service" = let
    inherit (cfg) downloadsDirectory;
    inherit (config.xdg) userDirs;

    symlink = link: target: {
      "${link}".L = {
        user = config.home.username;
        mode = "0770";
        argument = "${target}";
      };

      "${target}".d = {
        user = config.home.username;
        mode = "0770";
      };
    };
  in lib.mkMerge [
    (symlink "${downloadsDirectory}/books" "${userDirs.documents}/books/downloads")
    (symlink "${downloadsDirectory}/docs" "${userDirs.documents}/downloads")
    (symlink "${downloadsDirectory}/pictures" "${userDirs.pictures}/downloads")
    (symlink "${downloadsDirectory}/videos" "${userDirs.videos}/downloads")
  ];
}
