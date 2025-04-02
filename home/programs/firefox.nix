{ pkgs, ... }:
{
  programs.firefox = {
    enable = true;
    profiles.h7x4 = {
      bookmarks = [{
        toolbar = true;
        bookmarks = import ./browser/bookmarks.nix;
      }];
      search = {
        default = "Google";
        engines = import ./browser/engines.nix { inherit pkgs; };
        force = true;
      };

      # TODO: make into structured attrs
      settings = {
        # TODO: collect more stuff from here
        # https://github.com/arkenfox/user.js
        "browser.aboutConfig.showWarning" = false;
        "browser.newtabpage.activity-stream.showSponsored" = false;
        "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
        "browser.newtabpage.activity-stream.feeds.telemetry" = false;
        "browser.newtabpage.activity-stream.telemetry" = false;
        "datareporting.policy.dataSubmissionEnabled" = false;
        "datareporting.healthreport.uploadEnabled" = false;
        "toolkit.telemetry.unified" = false;
        "toolkit.telemetry.enabled" = false;
        "toolkit.telemetry.server" = "data:,";
        "toolkit.telemetry.archive.enabled" = false;
        "toolkit.telemetry.newProfilePing.enabled" = false;
        "toolkit.telemetry.shutdownPingSender.enabled" = false;
        "toolkit.telemetry.updatePing.enabled" = false;
        "toolkit.telemetry.bhrPing.enabled" = false;
        "toolkit.telemetry.firstShutdownPing.enabled" = false;
        "toolkit.telemetry.coverage.opt-out" = true;
        "toolkit.coverage.opt-out" = true;
        "toolkit.coverage.endpoint.base" = "";

        "font.cjk_pref_fallback_order" = lib.concatStringsSep "," [
          "ja"
          "zh-cn"
          "zh-hk"
          "zh-tw"
          "ko"
        ];
      } // (lib.pipe null [
        (_: {
          "ja" = "JP";
          "ko" = "KR";
          "zh-CN" = "SC";
          "zh-HK" = "HK";
          "zh-TW" = "TC";
        })
        (lib.mapAttrsToList (lang: notoSuffix: {
          "font.name.monospace.${lang}" = "Noto Sans Mono CJK ${notoSuffix}";
          "font.name.sans-serif.${lang}" = "Noto Sans CJK ${notoSuffix}";
          "font.name.serif.${lang}" = "Noto Serif CJK ${notoSuffix}";
        }))
        (lib.foldl lib.mergeAttrs { })
      ]);
    };
  };
}
