{ pkgs, ... }:
{
  fonts = {
    fontDir.enable = true;

    enableDefaultPackages = true;
    packages = with pkgs; [
      ark-pixel-font
      cm_unicode
      corefonts
      dejavu_fonts
      fira-code
      fira-code-symbols
      iosevka
      ipaexfont
      ipafont
      liberation_ttf
      migmix
      nerd-fonts._0xproto
      nerd-fonts.droid-sans-mono
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-emoji
      ocr-a
      open-sans
      powerline-fonts
      source-han-sans
      source-sans
      symbola
      texlivePackages.asana-math
      ubuntu_font_family
      victor-mono
      yasashisa-gothic
    ];

    fontconfig = {
      defaultFonts = {
        serif = [
          "Droid Sans Serif"
          "Noto Serif CJK JP"
          "Ubuntu"
        ];
        sansSerif = [
          "Droid Sans"
          "Noto Sans Serif CJK JP"
          "Ubuntu"
        ];
        monospace = [
          "Fira Code"
          "Noto Sans Mono CJK JP"
          "Ubuntu"
        ];
        emoji = [
          "Noto Sans Emoji"
        ];
      };
    };
  };
}
