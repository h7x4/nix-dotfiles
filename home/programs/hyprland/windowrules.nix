{ config, lib, ... }:
let
  cfg = config.wayland.windowManager.hyprland;
in
{
  config = lib.mkIf cfg.enable {
    wayland.windowManager.hyprland.settings.window_rule = [
      {
        match.class = "^(Rofi)$";
        float = true;
      }
      {
        match.class = "^(xdg-desktop-portal-gtk)$";
        float = true;
      }
      {
        match.title = "^(.*Bitwarden Password Manager.*)$";
        float = true;
      }
      {
        match.title = "^(Picture-in-Picture)$";
        float = true;
      }
      {
        match.class = "^(Nsxiv)$";
        tile = true;
      }

      {
        match.class = "^(Gimp-2.*)$";
        match.title = "^(Open Image)$";

        float = true;
        size = [
          "70%"
          "70%"
        ];
        center = true;
      }
      # {
      #   match.class = "^(xdg-desktop-portal-gtk)$";
      #   dimaround = true;
      # }

      {
        match.title = "^(Firefox — Sharing Indicator)$";
        workspace = "special:silent";
      }
      {
        match.title = "^(Zen — Sharing Indicator)$";
        workspace = "special:silent";
      }
      {
        match.title = "^(.*is sharing (your screen|a window)\\.)$";
        workspace = "special:silent";
      }

      {
      }

      {
        match.class = "^(firefox)$";
        workspace = 2;
      }
      {
        match.class = "^(chromium)$";
        workspace = 2;
      }

      {
        match.class = "^(Emacs)$";
        workspace = 3;
      }
      {
        match.class = "^(code)$";
        workspace = 3;
      }
      {
        match.class = "^(code-url-handler)$";
        workspace = 3;
      }
      {
        match.class = "^(dev.zed.Zed)$";
        workspace = 3;
      }

      {
        match.class = "^(discord)$";
        workspace = 5;
      }
      {
        match.class = "^(Element)$";
        workspace = 5;
      }

      {
        match.class = "^(anyrun)$";
        float = true;
      }
      {
        match.class = "^(xdg-desktop-portal-termfilechooser)$";
        float = true;
        size = [
          "70%"
          "80%"
        ];
        move = [
          "15%"
          "10%"
        ];
      }
    ];
  };
}
