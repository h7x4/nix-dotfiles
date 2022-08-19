{ lib, ... }:

let

  # Applications
  google-chrome = "google-chrome.desktop";
  gimp = "gimp.desktop";
  inkscape = "org.inkscape.Inkscape.desktop";
  vscode = "code.desktop";
  mpv = "mpv.desktop";
  zathura = "org.pwmt.zathura.desktop";
  sxiv = "sxiv.desktop";
  font-viewer = "org.gnome.font-viewer.desktop";

  # Formats
  "3g2-audio" = "audio/3gpp";
  "3g2-video" = "video/3gpp";
  "3gp-audio" = "audio/3gpp";
  "3gp-video" = "video/3gpp";
  aac = "audio/aac";
  avi = "video/x-msvideo";
  bmp = "image/bmp";
  cbr = "application/vnd.comicbook+rar";
  cbrx = "application/x-cbr";
  cbz = "application/vnd.comicbook+zip";
  cbzx = "application/x-cbz";
  djvu = "image/vnd.djvu";
  epub = "application/epub+zip";
  flv = "video/x-flv";
  gif = "image/gif";
  html = "text/html";
  http = "x-scheme-handler/http";
  https = "x-scheme-handler/https";
  ico = "image/vnd.microsoft.icon";
  icox = "image/x-icon";
  ini = "application/x-wine-extension-ini";
  jpg = "image/jpeg";
  m4v = "video/x-m4v";
  mkv = "video/x-matroska";
  mov = "video/quicktime";
  mp3 = "audio/mpeg";
  mp4 = "video/mp4";
  mpeg = "video/mpeg";
  ogg = "audio/ogg";
  ogv = "video/ogg";
  opus = "audio/opus";
  otf = "font/otf";
  pdf = "application/pdf";
  pic = "image/x-pict";
  png = "image/png";
  psd = "image/vnd.adobe.photoshop";
  svg = "image/svg+xml";
  tiff = "image/tiff";
  ttf = "font/ttf";
  txt = "text/plain";
  url = "application/x-mswinurl";
  wav = "audio/wav";
  wavx = "audio/x-wav";
  webm-audio = "audio/webm";
  webm-video = "video/webm";
  webp = "image/webp";
  wmv = "video/x-ms-wmv";
  woff = "font/woff";
  woff2 = "font/woff2";
  xbm = "image/x-xbitmap";
  xcf = "image/x-xcf";
  xhtml = "application/xhtml+xml";
  xml = "text/xml";
  xpm = "image/x-xpixmap";


  # Generalizations
  audio-player = mpv;
  gui-text-editor = vscode;
  image-viewer = sxiv;
  pdf-viewer = zathura;
  video-player = mpv;
  web-browser = google-chrome;

in {

  xdg.mimeApps = {
    enable = true;
    # associations.added = {};
    # associations.removed = {};
    defaultApplications = {
      ${"3g2-audio"} = audio-player;
      ${"3g2-video"} = video-player;
      ${"3gp-audio"} = audio-player;
      ${"3gp-video"} = video-player;
      ${aac} = audio-player;
      ${avi} = video-player;
      ${bmp} = image-viewer;
      ${cbrx} = zathura;
      ${cbr} = zathura;
      ${cbzx} = zathura;
      ${cbz} = zathura;
      ${djvu} = pdf-viewer;
      ${epub} = zathura;
      ${flv} = video-player;
      ${gif} = image-viewer;
      ${html} = web-browser;
      ${https} = web-browser;
      ${http} = web-browser;
      ${icox} = image-viewer;
      ${ico} = image-viewer;
      ${jpg} = image-viewer;
      ${m4v} = video-player;
      ${mkv} = video-player;
      ${mov} = video-player;
      ${mp3} = audio-player;
      ${mp4} = video-player;
      ${mpeg} = video-player;
      ${ogg} = audio-player;
      ${ogv} = video-player;
      ${opus} = audio-player;
      ${otf} = font-viewer;
      ${pdf} = pdf-viewer;
      ${pic} = image-viewer;
      ${png} = image-viewer;
      ${psd} = gimp;
      ${svg} = image-viewer;
      ${tiff} = image-viewer;
      ${ttf} = font-viewer;
      ${txt} = gui-text-editor;
      ${url} = web-browser;
      ${wav} = audio-player;
      ${webm-audio} = audio-player;
      ${webm-video} = video-player;
      ${webp} = image-viewer;
      ${wmv} = video-player;
      ${woff2} = font-viewer;
      ${woff} = font-viewer;
      ${xbm} = image-viewer;
      ${xcf} = gimp;
      ${xhtml} = web-browser;
      ${xml} = gui-text-editor;
      ${xpm} = image-viewer;
    };
  };
}

