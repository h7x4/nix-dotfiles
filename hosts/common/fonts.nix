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
      (nerdfonts.override { fonts = [ "FiraCode" "DroidSansMono" ]; })
    ];

    fontconfig = {
      defaultFonts = {
        serif = [ "Droid Sans Serif" "Ubuntu" ];
        sansSerif = [ "Droid Sans" "Ubuntu" ];
        monospace = [ "Fira Code" "Ubuntu" ];
        emoji = [ "Noto Sans Emoji" ];
      };
    };
  };
}
