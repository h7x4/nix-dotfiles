{ lib, ... }:
let
  mime = {
    image = {
      apng = "image/apng";
      avif = "image/avif";
      bmp = "image/bmp";
      gif = "image/gif";
      ico = "image/vnd.microsoft.icon";
      icox = "image/x-icon";
      jpg = "image/jpeg";
      jxl = "image/jxl";
      pic = "image/x-pict";
      png = "image/png";
      psd = "image/vnd.adobe.photoshop";
      svg = "image/svg+xml";
      tif = "image/tif";
      tiff = "image/tiff";
      webp = "image/webp";
      xbm = "image/x-xbitmap";
      xpm = "image/x-xpixmap";
    };

    audio = {
      "3g2-audio" = "audio/3gpp";
      "3gp-audio" = "audio/3gpp";
      aac = "audio/aac";
      aiff = "audio/aiff";
      flac = "audio/flac";
      mkv = "audio/x-matroska";
      mpeg = "audio/mpeg"; # NOTE: this is the real mp3, but the other one also exists
      mpeg3 = "audio/mpeg3";
      mp3 = "audio/mp3";
      mp4 = "audio/mp4";
      ogg = "audio/ogg";
      opus = "audio/opus";
      wav = "audio/wav";
      wavx = "audio/x-wav";
      webm-audio = "audio/webm";
    };

    video = {
      "3g2-video" = "video/3gpp";
      "3gp-video" = "video/3gpp";
      avi = "video/x-msvideo";
      flv = "video/x-flv";
      m4v = "video/x-m4v";
      mkv = "video/x-matroska";
      mov = "video/quicktime";
      mp4 = "video/mp4";
      mpeg = "video/mpeg";
      ogv = "video/ogg";
      webm-video = "video/webm";
      wmv = "video/x-ms-wmv";
    };

    font = {
      otf = "font/otf";
      ttf = "font/ttf";
      woff = "font/woff";
      woff2 = "font/woff2";
    };

    documents = {
      azv = "application/vnd.amazon.ebook";
      cbr = "application/vnd.comicbook+rar";
      cbrx = "application/x-cbr";
      cbz = "application/vnd.comicbook+zip";
      cbzx = "application/x-cbz";
      djvu = "image/vnd.djvu";
      epub = "application/epub+zip";
      pdf = "application/pdf";
    };

    code = {
      css = "text/css";
      csv = "text/csv";
      html = "text/html";
      txt = "text/plain";
      xhtml = "application/xhtml+xml";
      xml = "text/xml";
    };

    misc = {
      http = "x-scheme-handler/http";
      https = "x-scheme-handler/https";
      wine-ini = "application/x-wine-extension-ini";
      ics = "text/calendar";
      url = "application/x-mswinurl";
    };
  };

  # Applications
  firefox = "firefox.desktop";
  vscode = "code.desktop";
  mpv = "mpv.desktop";
  zathura = "org.pwmt.zathura.desktop";
  sxiv = "sxiv.desktop";
  font-viewer = "org.gnome.font-viewer.desktop";
in {
  xdg.configFile."mimeapps.list".force = true;
  xdg.mimeApps = {
    enable = true;
    # associations.added = {};
    # associations.removed = {};
    defaultApplications =
      (lib.mapAttrs' (_: v: lib.nameValuePair v sxiv) mime.image)
    // (lib.mapAttrs' (_: v: lib.nameValuePair v mpv) mime.audio)
    // (lib.mapAttrs' (_: v: lib.nameValuePair v mpv) mime.video)
    // (lib.mapAttrs' (_: v: lib.nameValuePair v font-viewer) mime.font)
    // (lib.mapAttrs' (_: v: lib.nameValuePair v zathura) mime.documents)
    // (lib.mapAttrs' (_: v: lib.nameValuePair v vscode) mime.code)
    // {
      ${mime.misc.http} = firefox;
      ${mime.misc.https} = firefox;
      ${mime.misc.wine-ini} = vscode;
      ${mime.misc.ics} = vscode;
      ${mime.misc.url} = firefox;
    };
  };
}

