{ pkgs, lib, config, ... }:
let
  im = config.i18n.inputMethod;
  cfg = im.fcitx5;
  fcitx5Package = pkgs.libsForQt5.fcitx5-with-addons.override { inherit (cfg) addons; };
in
{
  i18n.inputMethod = {
    enabled = "fcitx5";
    fcitx5.addons = with pkgs; [
      fcitx5-mozc
      fcitx5-gtk
      # fcitx5-chinese-addons
    ];
  };

  xdg.configFile = let
    format = pkgs.formats.iniWithGlobalSection { };
  in {
    "fcitx5/profile" = {
      force = true;
      source = format.generate "fcitx5-profile" {
        sections = {
          "Groups/0" = {
            Name = "Default";
            "Default Layout" = "us";
            DefaultIM = "mozc";
          };
          "Groups/0/Items/0" = {
            Name = "keyboard-us";
            Layout = "";
          };
          "Groups/0/Items/1" = {
            Name = "keyboard-no";
            Layout = "";
          };
          "Groups/0/Items/2" = {
            Name = "mozc";
            Layout = "";
          };
          GroupOrder = {
            "0" = "Default";
          };
        };
      };
    };

    "fcitx5/config".source = format.generate "fcitx5-config" {
      sections = {
        Hotkey = {
          # Enumerate when press trigger key repeatedly
          EnumerateWithTriggerKeys = "True";
          # Temporally switch between first and current Input Method
          AltTriggerKeys = "";
          # Enumerate Input Method Forward
          EnumerateForwardKeys = "";
          # Enumerate Input Method Backward
          EnumerateBackwardKeys = "";
          # Skip first input method while enumerating
          EnumerateSkipFirst = "False";
        };

        "Hotkey/TriggerKeys" = {
          "0" = "Control+space";
          "1" = "Zenkaku_Hankaku";
          "2" = "Hangul";
        };

        "Hotkey/EnumerateGroupForwardKeys"."0" = "Super+space";
        "Hotkey/EnumerateGroupBackwardKeys"."0" = "Shift+Super+space";
        "Hotkey/ActivateKeys"."0" = "Hangul_Hanja";
        "Hotkey/DeactivateKeys"."0" = "Hangul_Romaja";
        "Hotkey/PrevPage"."0" = "Up";
        "Hotkey/NextPage"."0" = "Down";
        "Hotkey/PrevCandidate"."0" = "Shift+Tab";
        "Hotkey/NextCandidate"."0" = "Tab";
        "Hotkey/TogglePreedit"."0" = "Control+Alt+P";

        Behaviour = {
          # Active By Default
          ActiveByDefault = "False";
          # Share Input State
          ShareInputState = "All";
          # Show preedit in application
          PreeditEnabledByDefault = "True";
          # Show Input Method Information when switch input method
          ShowInputMethodInformation = "True";
          # Show Input Method Information when changing focus
          showInputMethodInformationWhenFocusIn = "False";
          # Show compact input method information
          CompactInputMethodInformation = "True";
          # Show first input method information
          ShowFirstInputMethodInformation = "True";
          # Default page size
          DefaultPageSize = 5;
          # Override Xkb Option
          OverrideXkbOption = "False";
          # Custom Xkb Option
          CustomXkbOption = "";
          # Force Enabled Addons
          EnabledAddons = "";
          # Force Disabled Addons
          DisabledAddons = "";
          # Preload input method to be used by default
          PreloadInputMethod = "True";
          # Allow input method in the password field
          AllowInputMethodForPassword = "False";
          # Show preedit text when typing password
          ShowPreeditForPassword = "False";
          # Interval of saving user data in minutes
          AutoSavePeriod = 30;
        };
      };
    };

    "fcitx5/conf/classicui.conf".source = format.generate "fcitx5-classicui.conf" {
      globalSection = {
        Theme = "Material-Color";
        PerScreenDPI = "True";
        # Font = "";
        "Vertical Candidate List" = "True";
      };
    };
  };

  xdg.dataFile."fcitx5/themes/Material-Color" = {
    recursive = true;
    source = "${pkgs.fcitx5-material-color}/share/fcitx5/themes/Material-Color-orange";
  };

  systemd.user.services.fcitx5-daemon = {
    Service.Restart="on-failure";
    Service.ExecStart = lib.mkForce "${fcitx5Package}/bin/fcitx5";
    Service.ExecReload = "/bin/kill -HUP $MAINPID";
    Install.Alias = "fcitx5.service";
  };
}
