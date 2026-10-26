# pkgs/pkg_shortcircuit-xt.nix
{ lib
, stdenv
, fetchurl
, unzip
, autoPatchelfHook
, alsa-lib
, freetype
, curl
, libGL
, glib
, gtk3
, libxkbcommon
, libX11
, libXext
, libXrender
, libXcursor
, libXfixes
, libXi
, libXrandr
, libxcb
, xcbutil
, xcbutilcursor
}:

stdenv.mkDerivation rec {
  pname = "shortcircuit-xt";
  version = "2026-10-21-72ad423";

  src = fetchurl {
    url = "https://github.com/surge-synthesizer/shortcircuit-xt/releases/download/Nightly/shortcircuit-xt-linux-${version}.zip";
    hash = "sha256-ui6IjGyxTy1ENFOPogRhmxb5XbVsg6Yv0kBxHrncZic=";
  };

  nativeBuildInputs = [ unzip autoPatchelfHook ];

  buildInputs = [
    alsa-lib
    freetype
    curl
    libGL
    glib
    gtk3
    libxkbcommon
    libX11
    libXext
    libXrender
    libXcursor
    libXfixes
    libXi
    libXrandr
    libxcb
    xcbutil
    xcbutilcursor
    stdenv.cc.cc.lib
  ];

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/clap
    cp "shortcircuit-products/Shortcircuit XT.clap" $out/lib/clap/

    runHook postInstall
  '';

  meta = with lib; {
    description = "Shortcircuit XT – sample-based instrument (CLAP)";
    homepage = "https://github.com/surge-synthesizer/shortcircuit-xt";
    license = licenses.gpl3Only;
    platforms = [ "x86_64-linux" ];
    maintainers = [ ];
  };
}
