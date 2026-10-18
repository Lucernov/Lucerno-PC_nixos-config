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
  pname = "je8086";
  version = "2.2.27";

  src = fetchurl {
    url = "https://github.com/dsp56300/gearmulator/releases/download/${finalAttrs.version}/TheUsualSuspects-JE8086-CLAP-${finalAttrs.version}-Linux_x86_64.zip";
    hash = "sha256-rf+/tpNKpLmvLPULifq36uN67mb1yEJ1vkqn0fRGW50=";
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
    cp usr/local/lib/clap/JE8086.clap $out/lib/clap/
    runHook postInstall
  '';

  meta = with lib; {
    description = "JE8086 – Roland JP-8000 emulation (CLAP)";
    homepage = "https://theusualsuspects.io/downloads/je8086";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ sourceTypes.binaryNativeCode ];
    maintainers = [ ];
  };
})
