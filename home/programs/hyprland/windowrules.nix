{ config, lib, ... }:
let
  cfg = config.wayland.windowManager.hyprland;
in
{
  config = lib.mkIf cfg.enable {
    wayland.windowManager.hyprland.settings.windowrulev2 = [
      "float, class:^(Rofi)$"
      "float, class:^(xdg-desktop-portal-gtk)$"
      "float, title:^(.*Bitwarden Password Manager.*)$"
      "float, title:^(Picture-in-Picture)$"
      "tile, class:^(Nsxiv)$"

      "float, class: ^(Gimp-2.*)$, title:^(Open Image)$"
      "size 70%, class: ^(Gimp-2.*)$, title:^(Open Image)$"
      "center, class: ^(Gimp-2.*)$, title:^(Open Image)$"

      "dimaround, class:^(xdg-desktop-portal-gtk)$"

      "workspace special silent, title:^(Firefox — Sharing Indicator)$"
      "workspace special silent, title:^(Zen — Sharing Indicator)$"
      "workspace special silent, title:^(.*is sharing (your screen|a window)\.)$"

      "workspace 2, class:^(firefox)$"
      "workspace 2, class:^(google-chrome)$"

      "workspace 3, class:^(Emacs)$"
      "workspace 3, class:^(code)$"
      "workspace 3, class:^(code-url-handler)$"
      "workspace 3, class:^(dev.zed.Zed)$"

      "workspace 5, class:^(discord)$"
      "workspace 5, class:^(Element)$"

      "float, class:^(xdg-desktop-portal-termfilechooser)$"
      "size 70% 80%, class:^(xdg-desktop-portal-termfilechooser)$"
      "move 15% 10%, class:^(xdg-desktop-portal-termfilechooser)$"
    ];
  };
}
