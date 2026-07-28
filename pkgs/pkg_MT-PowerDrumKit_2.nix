{ lib
, stdenv
, fetchurl
, unzip
, autoPatchelfHook
, libX11
, libXext
, libXrender
, libXcursor
, libXfixes
, libXi
, libXrandr
, libxcb
, libxkbcommon
, glib
, fontconfig
, cairo
, pango
, zlib
, freetype
, libpng
}:

stdenv.mkDerivation {
  pname = "mtpdk";
  version = "2.1.5.1";

  src = fetchurl {
    url = "https://resources.manda-audio.com/DOWNLOADS/products/mtpdk2_free/2.1.5/MTPDK-2.1.5.1-VST3-64bit-Linux-FULL.zip";
    hash = "sha256-lb8RuIdLgDC2y9KSF6hlWXWKlt4jI8tndWk/WVanpGo=";
  };

  nativeBuildInputs = [ unzip autoPatchelfHook ];

  buildInputs = [
    libX11
    libXext
    libXrender
    libXcursor
    libXfixes
    libXi
    libXrandr
    libxcb
    libxkbcommon
    glib
    cairo
    pango
    fontconfig
    freetype
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
