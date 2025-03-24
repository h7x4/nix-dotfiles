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

    archive = {
      "7z" = "application/x-7z-compressed";
      ar = "application/x-archive";
      bz2 = "application/x-bzip2";
      deb = "application/x-debian-package";
      gzip = "application/gzip";
      lz = "application/x-lzip";
      lzma = "application/x-lzma";
      lzo = "application/x-lzop";
      rar = "application/vnd.rar";
      rar-compressed = "application/x-rar-compressed";
      tar = "application/x-tar";
      tar-compressed = "application/x-gtar";
      x-zip = "multipart/x-zip";
      xz = "application/x-xz";
      zip = "application/zip";
      zip-compressed = "application/x-zip-compressed";
      zst = "application/zstd";
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

    office = {
      doc = "application/msword";
      docm = "application/vnd.ms-word.document.macroEnabled.12";
      docx = "application/vnd.openxmlformats-officedocument.wordprocessingml.document";
      dot = "application/msword";
      dotm = "application/vnd.ms-word.template.macroEnabled.12";
      dotx = "application/vnd.openxmlformats-officedocument.wordprocessingml.template";
      mdb = "application/vnd.ms-access";
      pot = "application/vnd.ms-powerpoint";
      potm = "application/vnd.ms-powerpoint.template.macroEnabled.12";
      potx = "application/vnd.openxmlformats-officedocument.presentationml.template";
      ppa = "application/vnd.ms-powerpoint";
      ppam = "application/vnd.ms-powerpoint.addin.macroEnabled.12";
      pps = "application/vnd.ms-powerpoint";
      ppsm = "application/vnd.ms-powerpoint.slideshow.macroEnabled.12";
      ppsx = "application/vnd.openxmlformats-officedocument.presentationml.slideshow";
      ppt = "application/vnd.ms-powerpoint";
      pptm = "application/vnd.ms-powerpoint.presentation.macroEnabled.12";
      pptx = "application/vnd.openxmlformats-officedocument.presentationml.presentation";
      xla = "application/vnd.ms-excel";
      xlam = "application/vnd.ms-excel.addin.macroEnabled.12";
      xls = "application/vnd.ms-excel";
      xlsb = "application/vnd.ms-excel.sheet.binary.macroEnabled.12";
      xlsm = "application/vnd.ms-excel.sheet.macroEnabled.12";
      xlsx = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet";
      xlt = "application/vnd.ms-excel";
      xltm = "application/vnd.ms-excel.template.macroEnabled.12";
      xltx = "application/vnd.openxmlformats-officedocument.spreadsheetml.template";

      odc = "application/vnd.oasis.opendocument.chart";
      odf = "application/vnd.oasis.opendocument.formula";
      odg = "application/vnd.oasis.opendocument.graphics";
      odi = "application/vnd.oasis.opendocument.image";
      odm = "application/vnd.oasis.opendocument.text-master";
      odp = "application/vnd.oasis.opendocument.presentation";
      odt = "application/vnd.oasis.opendocument.text";
      otg = "application/vnd.oasis.opendocument.graphics-template";
      oth = "application/vnd.oasis.opendocument.text-web";
      otm = "application/vnd.oasis.opendocument.text-master-template";
      otp = "application/vnd.oasis.opendocument.presentation-template";
      ots = "application/vnd.oasis.opendocument.spreadsheet-template";
      ott = "application/vnd.oasis.opendocument.text-template";
    };

    code = {
      css = "text/css";
      csv = "text/csv";
      html = "text/html";
      js = "application/x-javascript";
      latex = "application/x-latex";
      php = "application/x-httpd-php";
      pl = "application/x-perl";
      rtf = "application/rtf";
      sh = "application/x-sh";
      tex = "application/x-tex";
      txt = "text/plain";
      xhtml = "application/xhtml+xml";
      xml = "text/xml";
    };

    web = {
      about = "x-scheme-handler/about";
      chrome = "x-scheme-handler/chrome";
      html = "text/html";
      http = "x-scheme-handler/http";
      https = "x-scheme-handler/https";
      mxwinurl = "application/x-mswinurl";
      unknown = "x-scheme-handler/unknown";
      x-htm = "application/x-extension-htm";
      x-html = "application/x-extension-html";
      x-shtml = "application/x-extension-shtml";
      x-xht = "application/x-extension-xht";
      x-xhtml = "application/x-extension-xhtml";
      xhtml-xml = "application/xhtml+xml";
    };

    misc = {
      ics = "text/calendar";
      wine-ini = "application/x-wine-extension-ini";
      wine-osz = "application/x-wine-extension-osz";
    };
  };

  # Applications
  ark = "org.kde.ark.desktop";
  firefox = "firefox.desktop";
  zed = "dev.zed.Zed.desktop";
  mpv = "mpv.desktop";
  zathura = "org.pwmt.zathura.desktop";
  nsxiv = "nsxiv.desktop";
  font-viewer = "org.gnome.font-viewer.desktop";
  libreoffice = "startcenter.desktop";
in {
  xdg.configFile."mimeapps.list".force = true;
  xdg.mimeApps = {
    enable = true;
    # associations.added = {};
    # associations.removed = {};
    defaultApplications =
      (lib.mapAttrs' (_: v: lib.nameValuePair v nsxiv) mime.image)
    // (lib.mapAttrs' (_: v: lib.nameValuePair v mpv) mime.audio)
    // (lib.mapAttrs' (_: v: lib.nameValuePair v mpv) mime.video)
    // (lib.mapAttrs' (_: v: lib.nameValuePair v font-viewer) mime.font)
    // (lib.mapAttrs' (_: v: lib.nameValuePair v libreoffice) mime.office)
    // (lib.mapAttrs' (_: v: lib.nameValuePair v zathura) mime.documents)
    // (lib.mapAttrs' (_: v: lib.nameValuePair v zed) mime.code)
    // (lib.mapAttrs' (_: v: lib.nameValuePair v ark) mime.archive)
    // (lib.mapAttrs' (_: v: lib.nameValuePair v firefox) mime.web)
    // {
      ${mime.misc.wine-ini} = zed;
      ${mime.misc.ics} = zed;
    };
  };
}

