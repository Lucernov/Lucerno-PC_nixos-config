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
  version = versions.je8086;
in

stdenv.mkDerivation {
  pname = "je8086";
  inherit version;

  src = fetchurl {
    url = "https://github.com/dsp56300/gearmulator/releases/download/${version}/TheUsualSuspects-JE8086-CLAP-${version}-Linux_x86_64.zip";
    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # Заменить на реальный
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
    cp usr/local/lib/clap/JE8086.clap $out/lib/clap/

    runHook postInstall
  '';

  meta = with lib; {
    description = "JE8086 – Roland JP-8000 emulation (CLAP)";
    homepage = "https://theusualsuspects.io/";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ sourceTypes.binaryNativeCode ];
    maintainers = [ ];
  };
}
