{ lib
, stdenv
, fetchurl
, unzip
, autoPatchelfHook
, libX11
, libxcb
, libxkbcommon
, xcbutil
, xcbutilcursor
, glib
, fontconfig
, cairo
, pango
, zlib
, freetype
, libpng
, libxcb-keysyms
, versions
}:

let
  inherit (versions.mtpdk) version urlVersion hash;
in

stdenv.mkDerivation {
  pname = "mtpdk";
  inherit version;

  src = fetchurl {
    url = "https://resources.manda-audio.com/DOWNLOADS/products/mtpdk2_free/${urlVersion}/MTPDK-${version}-VST3-64bit-Linux-FULL.zip";
    inherit hash;
  };

  nativeBuildInputs = [ unzip autoPatchelfHook ];

  buildInputs = [
    libX11
    libxcb
    xcbutil
    xcbutilcursor
    libxcb-keysyms
    libxkbcommon
    freetype
    glib
    cairo
    pango
    fontconfig
    libpng
    zlib
  ];

  sourceRoot = ".";

  unpackPhase = ''
    runHook preUnpack
    unzip $src
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib/vst3
    cp -r MT-PowerDrumKit.vst3 $out/lib/vst3/
    runHook postInstall
  '';

  meta = with lib; {
    description = "MT Power Drum Kit - Free acoustic drum kit VST3 plugin";
    homepage = "https://www.powerdrumkit.com/";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ sourceTypes.binaryNativeCode ];
  };
}
