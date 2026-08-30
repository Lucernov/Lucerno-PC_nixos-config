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
, versions
}:

let
  version = versions.shortcircuit-xt;
in

stdenv.mkDerivation {
  pname = "shortcircuit-xt";
  inherit version;

  src = fetchurl {
    url = "https://github.com/surge-synthesizer/shortcircuit-xt/releases/download/Nightly/shortcircuit-xt-linux-2026-07-31-7d79b3a.zip";
    hash = "sha256-dbod6Bc7W2+ul0IUXFg9Olai75VhLAtXMobj3kgdklI=";
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
