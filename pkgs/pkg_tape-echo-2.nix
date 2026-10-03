{ lib
, stdenv
, fetchurl
, unzip
, autoPatchelfHook
, libX11
, libXext
, libGL
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "tape-echo-2";
  version = "1.0.7";

  src = fetchurl {
    # Тег на GitHub: tape-echo-2-v1.0.7 (префикс + версия)
    # nix-update сам подставит новую версию в ${finalAttrs.version}
    url = "https://github.com/dusk-audio/dusk-audio-plugins/releases/download/tape-echo-2-v${finalAttrs.version}/tape-echo-2-linux.zip";
    hash = "sha256-8KJ/qGzGKhGRGpKvrdu3Mbs+8A4gPGIovTKrfDCpL0g=";
  };

  nativeBuildInputs = [ unzip autoPatchelfHook ];

  buildInputs = [
    libX11
    libXext
    libGL
    stdenv.cc.cc.lib   # libstdc++
  ];

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    # VST3
    mkdir -p $out/lib/vst3
    cp -r tape-echo-2-linux/VST3/tape-echo-2.vst3 $out/lib/vst3/

    # CLAP
    mkdir -p $out/lib/clap
    cp tape-echo-2-linux/CLAP/tape-echo-2.clap $out/lib/clap/

    # LV2
    mkdir -p $out/lib/lv2
    cp -r tape-echo-2-linux/LV2/tape-echo-2.lv2 $out/lib/lv2/

    # Документация
    mkdir -p $out/share/doc/tape-echo-2
    cp tape-echo-2-linux/tape-echo-2-manual.pdf $out/share/doc/tape-echo-2/
    cp tape-echo-2-linux/LICENSE $out/share/doc/tape-echo-2/
    cp tape-echo-2-linux/THIRD_PARTY_LICENSES.md $out/share/doc/tape-echo-2/

    runHook postInstall
  '';

  meta = with lib; {
    description = "Tape Echo 2 — эмуляция Roland Space Echo (VST3, CLAP, LV2)";
    homepage = "https://github.com/dusk-audio/dusk-audio-plugins";
    license = licenses.gpl3Only;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ sourceTypes.binaryNativeCode ];
  };
})
