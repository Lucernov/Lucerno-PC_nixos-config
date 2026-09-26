{ lib
, stdenv
, fetchurl
, unzip
, autoPatchelfHook
, patchelf
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

  nativeBuildInputs = [ unzip autoPatchelfHook patchelf ];

  buildInputs = [
    alsa-lib
    freetype
    stdenv.cc.cc.lib   # libstdc++, libgcc_s, libatomic
  ];

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    # CLAP
    mkdir -p $out/lib/clap
    cp TAL-Vocoder-2/TAL-Vocoder-2.clap $out/lib/clap/

    # VST3
    mkdir -p $out/lib/vst3
    cp -r TAL-Vocoder-2/TAL-Vocoder-2.vst3 $out/lib/vst3/

    # Общая библиотека — в отдельную папку, потому что она подгружается
    # через dlopen(), а не через NEEDED
    mkdir -p $out/lib/TAL-Vocoder-2
    cp TAL-Vocoder-2/libTAL-Vocoder-2.so $out/lib/TAL-Vocoder-2/

    # Документация
    mkdir -p $out/share/doc/tal-vocoder-2
    cp TAL-Vocoder-2/ReadmeLinux.txt $out/share/doc/tal-vocoder-2/

    runHook postInstall
  '';

  # libTAL-Vocoder-2.so подгружается через dlopen() — autoPatchelfHook её
  # не видит, поэтому rpath добавляем вручную. autoPatchelfHook выполняется
  # до postFixup, так что --add-rpath дополняет уже прописанные системные пути.
  postFixup = ''
    patchelf --add-rpath "$out/lib/TAL-Vocoder-2" \
      "$out/lib/clap/TAL-Vocoder-2.clap" \
      "$out/lib/vst3/TAL-Vocoder-2.vst3/Contents/x86_64-linux/TAL-Vocoder-2.so"
  '';

  meta = with lib; {
    description = "TAL-Vocoder-2 — vintage-style vocoder plugin (VST3 + CLAP)";
    homepage = "https://tal-software.com/products/tal-vocoder";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ sourceTypes.binaryNativeCode ];
  };
}
