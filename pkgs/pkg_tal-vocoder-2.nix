{ lib
, stdenv
, fetchurl
, unzip
, autoPatchelfHook
, alsa-lib
, freetype
, versions
}:

let
  inherit (versions.tal-vocoder-2) version url hash;
in

stdenv.mkDerivation {
  pname = "tal-vocoder-2";
  inherit version;

  src = fetchurl {
    inherit url hash;
  };

  nativeBuildInputs = [ unzip autoPatchelfHook ];

  buildInputs = [
    alsa-lib
    freetype
    stdenv.cc.cc.lib
  ];

  # libTAL-Vocoder-2.so подгружается через dlopen(), не через NEEDED,
  # поэтому autoPatchelfHook её не видит. appendRunpaths добавляет
  # $ORIGIN в финальный rpath, который auto-patchelf сам прописывает.
  # $ORIGIN = папка самого плагина → dlopen найдёт libTAL рядом.
  appendRunpaths = [ "$ORIGIN" ];

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    # CLAP + lib рядом
    mkdir -p $out/lib/clap
    cp TAL-Vocoder-2/TAL-Vocoder-2.clap $out/lib/clap/
    cp TAL-Vocoder-2/libTAL-Vocoder-2.so $out/lib/clap/

    # VST3 + lib рядом
    mkdir -p $out/lib/vst3/TAL-Vocoder-2.vst3/Contents/x86_64-linux
    cp TAL-Vocoder-2/TAL-Vocoder-2.vst3/Contents/x86_64-linux/TAL-Vocoder-2.so \
      $out/lib/vst3/TAL-Vocoder-2.vst3/Contents/x86_64-linux/
    cp TAL-Vocoder-2/libTAL-Vocoder-2.so \
      $out/lib/vst3/TAL-Vocoder-2.vst3/Contents/x86_64-linux/

    # Документация
    mkdir -p $out/share/doc/tal-vocoder-2
    cp TAL-Vocoder-2/ReadmeLinux.txt $out/share/doc/tal-vocoder-2/

    runHook postInstall
  '';

  meta = with lib; {
    description = "TAL-Vocoder-2 — vintage-style vocoder plugin (VST3 + CLAP)";
    homepage = "https://tal-software.com/products/tal-vocoder";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ sourceTypes.binaryNativeCode ];
  };
}
