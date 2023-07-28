{
  lib,

  stdenvNoCC,
  fetchFromGitHub
}:
stdenvNoCC.mkDerivation rec {
  pname = "fcitx5-material-color";
  version = "0.2.1";

  src = fetchFromGitHub {
    owner = "hosxy";
    repo = "Fcitx5-Material-Color";
    rev = "${version}";
    sha256 = "i9JHIJ+cHLTBZUNzj9Ujl3LIdkCllTWpO1Ta4OT1LTc=";
  };

  outputs = [ "out" "doc" ];

  installPhase = ''
    runHook preInstall

    install -Dm644 -t $out/usr/share/fcitx5/themes/fcitx5-material-color radio.png arrow.png

    find $src -type f -name 'theme*.conf' \
      -exec install -Dm644 -t $out/usr/share/fcitx5/themes/fcitx5-material-color {} +

    find $src/screenshot -type f \
      -exec install -Dm644 -t $doc/usr/share/doc/fcitx5/themes/fcitx5-material-color {} +

    install -Dm644 -t $doc/usr/share/doc/fcitx5/themes/fcitx5-material-color \
      LICENSE \
      README.md

    runHook postInstall
  '';

  meta = with lib; {
    description = "";
    longDescription = ''
      A fcitx5 skin with colors from Material Design.
      Designed to mimick the interface of the Windows 10 IME.
    '';
    homepage = "https://github.com/hosxy/Fcitx5-Material-Color";
    license = licenses.asl20;
    maintainers = [ maintainers.h7x4 ];
    platforms = platforms.all;
  };
}
