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

stdenv.mkDerivation {
  pname = "ostirus";
  version = "2.2.9";

  src = fetchurl {
    url = "https://github.com/dsp56300/gearmulator/releases/download/2.2.9/TheUsualSuspects-OsTIrus-CLAP-2.2.9-Linux_x86_64.zip";
    hash = "sha256-hyH5HkTxxXfuiWqQz2gsE2FTT5fWdjYFtGL7JcWMi/Q=";
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
}
