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

stdenv.mkDerivation (finalAttrs: {
  pname = "ostirus";
  version = "2.2.25";

  src = fetchurl {
    url = "https://github.com/dsp56300/gearmulator/releases/download/${finalAttrs.version}/TheUsualSuspects-OsTIrus-CLAP-${finalAttrs.version}-Linux_x86_64.zip";
    hash = "sha256-2idnSMHn4Yyw3aZfvrlVjYQQvH6/0qUsd8AzNMMwL4M=";
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

    # Устанавливаем CLAP-плагин
    mkdir -p $out/lib/clap
    cp usr/local/lib/clap/OsTIrus.clap $out/lib/clap/

    runHook postInstall
  '';

  meta = with lib; {
    description = "OsTIrus – Access Virus TI emulation in CLAP format";
    homepage = "https://github.com/dsp56300/gearmulator";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ sourceTypes.binaryNativeCode ];
  };
})
