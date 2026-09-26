# pkgs/pkg_pitchnet.nix
#
# Особенности:
#   - PitchNet распространяется как Makeself-архив (.run), не tar/zip.
#     Распаковываем через `sh $src --noexec --target .` — распаковка без
#     запуска install.sh (который требует root и ставит в /opt).
#   - libonnxruntime.so.1 и libonnxruntime_providers_shared.so — бандл
#     в payload/opt/Session Loops/PitchNet/lib/. Их нет в buildInputs,
#     поэтому добавлены в autoPatchelfIgnoreMissingDeps.
#   - postFixup добавляет $out/share/pitchnet/lib в rpath VST3, иначе
#     autoPatchelfHook прописывает только системные пути, и onnxruntime
#     не находится.
#   - Standalone НЕ устанавливается: падает при старте с SEGV в
#     juce::Component::centreWithSize (баг JUCE на Linux). VST3 в REAPER
#     работает нормально.

{ lib
, stdenv
, fetchurl
, autoPatchelfHook
, patchelf
, alsa-lib
, freetype
, fontconfig
, versions
}:

let
  inherit (versions.pitchnet) version url hash;
in

stdenv.mkDerivation {
  pname = "pitchnet";
  inherit version;

  src = fetchurl {
    inherit url hash;
  };

  nativeBuildInputs = [ autoPatchelfHook patchelf ];

  buildInputs = [
    alsa-lib
    freetype
    fontconfig
    stdenv.cc.cc.lib
  ];

  autoPatchelfIgnoreMissingDeps = [
    "libonnxruntime.so.1"
    "libonnxruntime_providers_shared.so"
  ];

  unpackPhase = ''
    runHook preUnpack
    sh $src --noexec --target .
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    # Только ресурсы, которые нужны VST3-плагину.
    # Standalone-бинарник PitchNet НЕ устанавливается:
    # он падает при старте из-за бага JUCE (centreWithSize в initialise()).
    # Сам VST3 в REAPER работает нормально.
    mkdir -p $out/share/pitchnet
    cp -r "payload/opt/Session Loops/PitchNet/models" $out/share/pitchnet/
    cp -r "payload/opt/Session Loops/PitchNet/lib"    $out/share/pitchnet/
    cp -r "payload/opt/Session Loops/PitchNet/fonts"  $out/share/pitchnet/
    cp -r "payload/opt/Session Loops/PitchNet/lang"   $out/share/pitchnet/
    chmod -R u+w $out/share/pitchnet

    # VST3
    mkdir -p $out/lib/vst3
    cp -r payload/vst3/PitchNet.vst3 $out/lib/vst3/
    chmod -R u+w $out/lib/vst3/PitchNet.vst3

    runHook postInstall
  '';

  # autoPatchelfHook перезаписал rpath → добавляем путь к бандлу onnxruntime
  postFixup = ''
    patchelf --add-rpath "$out/share/pitchnet/lib" \
      "$out/lib/vst3/PitchNet.vst3/Contents/x86_64-linux/PitchNet.so"
  '';

  meta = with lib; {
    description = "PitchNet – neural pitch correction plugin (VST3 only)";
    homepage = "https://github.com/SessionLoops/PitchNet";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ sourceTypes.binaryNativeCode ];
  };
}
