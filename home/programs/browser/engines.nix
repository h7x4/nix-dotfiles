{ pkgs, ... }:
{
  "Amazon.com".metaData.hidden = true;
  "Bing".metaData.hidden = true;
  "Wikipedia (en)".metaData.hidden = true;
  "Google".metaData.alias = "gg";
  "DuckDuckGo".metaData.alias = "dd";

  "Arch Package Repository" = {
    urls = [{
      template = "https://www.archlinux.org/packages/";
      params = [{ name = "q"; value = "{searchTerms}"; }];
    }];
    icon = "${pkgs.super-tiny-icons}/share/icons/SuperTinyIcons/svg/arch_linux.svg";
    definedAliases = [ "pac" ];
  };

  "Arch Wiki" = {
    urls = [{
      template = "https://wiki.archlinux.org/index.php";
      params = [
        { name = "title"; value = "Special:Search"; }
        { name = "search"; value = "{searchTerms}"; }
      ];
    }];
    icon = "${pkgs.super-tiny-icons}/share/icons/SuperTinyIcons/svg/arch_linux.svg";
    definedAliases = [ "aw" ];
  };

  "AUR" = {
    urls = [{
      template = "https://aur.archlinux.org/packages/";
      params = [
        { name = "O"; value = "0"; }
        { name = "K"; value = "{searchTerms}"; }
      ];
    }];
    icon = "${pkgs.super-tiny-icons}/share/icons/SuperTinyIcons/svg/arch_linux.svg";
    definedAliases = [ "aur" ];
  };

  "Dart Packages" = {
    urls = [{
      template = "https://pub.dev/packages";
      params = [{ name = "q"; value = "{searchTerms}"; }];
    }];
    icon = "${pkgs.super-tiny-icons}/share/icons/SuperTinyIcons/svg/dart.svg";
    definedAliases = [ "pub" ];
  };

  "GitHub" = {
    urls = [{
      template = "https://github.com/search";
      params = [{ name = "q"; value = "{searchTerms}"; }];
    }];
    icon = "${pkgs.super-tiny-icons}/share/icons/SuperTinyIcons/svg/github.svg";
    definedAliases = [ "gh" ];
  };

  "HomeManager Options" = {
    urls = [{
      template = "https://mipmip.github.io/home-manager-option-search/?{searchTerms}";
    }];
    icon = "${pkgs.super-tiny-icons}/share/icons/SuperTinyIcons/svg/nixos.svg";
    definedAliases = [ "hms" ];
  };

  "Hoogle" = {
    urls = [{
      template = "https://hoogle.haskell.org/";
      params = [{ name = "hoogle"; value = "{searchTerms}"; }];
    }];
    # TODO: this has got to have an icon of some sort...
    # icon = "${pkgs.super-tiny-icons}/share/icons/SuperTinyIcons/svg/haskell.svg";
    definedAliases = [ "hg" ];
  };

  "Melpa" = {
    urls = [{
      template = "https://melpa.org/";
      params = [{ name = "q"; value = "{searchTerms}"; }];
    }];
    definedAliases = [ "mel" ];
  };

  "MyAnimeList" = {
    urls = [{
      template = "https://myanimelist.net/anime.php";
      params = [{ name = "q"; value = "{searchTerms}"; }];
    }];
    definedAliases = [ "mal" ];
  };

  "NixOS Options" = {
    urls = [{
      template = "https://search.nixos.org/options";
      params = [{ name = "query"; value = "{searchTerms}"; }];
    }];
    icon = "${pkgs.super-tiny-icons}/share/icons/SuperTinyIcons/svg/nixos.svg";
    definedAliases = [ "nxo" ];
  };

  "Nixpkgs Packages" = {
    urls = [{
      template = "https://search.nixos.org/packages";
      params = [{ name = "query"; value = "{searchTerms}"; }];
    }];
    icon = "${pkgs.super-tiny-icons}/share/icons/SuperTinyIcons/svg/nixos.svg";
    definedAliases = [ "nxp" ];
  };

  "Pixabay" = {
    urls = [{
      template = "https://pixabay.com/images/search/{searchTerms}/";
    }];
    definedAliases = [ "pix" "pxb" ];
  };

  "RomajiDesu" = {
    urls = [{
      template = "https://www.romajidesu.com/dictionary/meaning-of-{searchTerms}.html";
    }];
    definedAliases = [ "rd" "rom" ];
  };

  "SynonymOrdboka" = {
    urls = [{
      template = "https://www.synonymordboka.no/no/";
      params = [{ name = "q"; value = "{searchTerms}"; }];
    }];
    definedAliases = [ "syn" ];
  };

  "Translate" = {
    urls = [{
      template = "https://translate.google.com/?#auto|auto|{searchTerms}";
    }];
    icon = "${pkgs.super-tiny-icons}/share/icons/SuperTinyIcons/svg/google.svg";
    definedAliases = [ "tr" ];
  };

  "Unicode Character Table" = {
    urls = [{
      template = "https://unicode-table.com/en/search/?p&q={searchTerms}";
    }];
    definedAliases = [ "ut" ];
  };

  "YouTube" = {
    urls = [{
      template = "https://www.youtube.com/results";
      params = [{ name = "search_query"; value = "{searchTerms}"; }];
    }];
    icon = "${pkgs.super-tiny-icons}/share/icons/SuperTinyIcons/svg/youtube.svg";
    definedAliases = [ "yt" ];
  };

  "辞書" = {
    urls = [{
      template = "https://jisho.org/search/{searchTerms}";
      params = [{ name = "color_theme"; value = "dark"; }];
    }];
    definedAliases = [ "js" ];
  };

  "辞書漢字" = {
    urls = [{
      template = "https://jisho.org/search/%23kanji%20{searchTerms}";
      params = [{ name = "color_theme"; value = "dark"; }];
    }];
    definedAliases = [ "kan" ];
  };
}
