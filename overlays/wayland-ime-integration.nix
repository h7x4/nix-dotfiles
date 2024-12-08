final: prev: let
  inherit (prev) lib;

  wrapWithWaylandIMEFlag = pkg: let
    binaryName = lib.removePrefix "${lib.getBin pkg}/bin/" (lib.getExe pkg);
  in pkg.overrideAttrs (prev': {
    postInstall = (prev'.postInstall or "") + ''
      wrapProgram "$out/bin/${binaryName}" \
        --add-flags "--enable-wayland-ime --wayland-text-input-version=3"
    '';
  });

  programList = [
    "element-desktop"
    "vscode"
    "chromium"
    "discord"
  ];
in
  lib.genAttrs programList (name: wrapWithWaylandIMEFlag prev.${name})
