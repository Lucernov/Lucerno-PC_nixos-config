{ lib
, stdenv
, fetchurl
, unzip
, autoPatchelfHook
, xorg
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
    hash = ""; # После первой сборки подставьте правильный хеш
  };

  nativeBuildInputs = [ unzip autoPatchelfHook ];

  buildInputs = [
    xorg.libX11
    xorg.libXext
    xorg.libXrender
    xorg.libXcursor
    xorg.libXfixes
    xorg.libXi
    xorg.libXrandr
    xorg.libxcb
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

    mkdir -p $out/share/mtpdk
    cp MT-PowerDrumKit-Content.pdk $out/share/mtpdk/

    ln -s $out/share/mtpdk/MT-PowerDrumKit-Content.pdk \
          $out/lib/vst3/MT-PowerDrumKit.vst3/Contents/x86_64-linux/MT-PowerDrumKit-Content.pdk

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
