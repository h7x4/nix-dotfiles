{ ... }:
{
  services.jitsi-meet = {
    enable = true;
    hostName = "jitsi.nani.wtf";
    config = {
      enableWelcomePage = false;
      prejoinPageEnabled = true;
      defaultLang = "en";
    };
    interfaceConfig = {
      SHOW_JITSI_WATERMARK = false;
      SHOW_WATERMARK_FOR_GUESTS = false;
    };
  };
}
