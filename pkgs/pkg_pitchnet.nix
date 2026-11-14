# pkgs/pkg_pitchnet.nix
#
# Особенности:
#   - PitchNet распространяется как Makeself-архив (.run), не tar/zip Распаковываем через `sh $src --noexec --target .` — распаковка без запуска install.sh (который требует root и ставит в /opt)
#   - В 0.8.1 структура архива изменилась: вместо payload/opt/Session Loops/PitchNet/ ресурсы теперь лежат в payload/app/. VST3 bundle теперь ещё и содержит вкомпилированный libonnxruntime в Contents/x86_64-linux/lib/
#   - autoPatchelfIgnoreMissingDeps — страховка на случай, если autoPatchelfHook не найдёт onnxruntime в $out. В 0.8.1 он его находит (и в VST3 bundle, и в $out/share/pitchnet/lib/), но оставляем для совместимости
#   - Standalone НЕ устанавливается: падает при старте с SEGV в juce::Component::centreWithSize (баг JUCE на Linux). VST3 в REAPER работает нормально

{ lib
, stdenv
, fetchurl
, autoPatchelfHook
, alsa-lib
, freetype
, fontconfig
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "pitchnet";
  version = "0.8.1";

  src = fetchurl {
    url = "https://github.com/SessionLoops/PitchNet/releases/download/v${finalAttrs.version}/PitchNet-Linux-x86_64.run";
    hash = "sha256-UsNMxBcI39HZWghLEa91EdpJe+4SrGNW/jpH5Gs34ik=";
  };

  nativeBuildInputs = [ autoPatchelfHook ];

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

    # В 0.8.1 ресурсы лежат в payload/app/ (раньше было payload/opt/Session Loops/PitchNet/)
    mkdir -p $out/share/pitchnet
    cp -r payload/app/models $out/share/pitchnet/
    cp -r payload/app/lib    $out/share/pitchnet/
    cp -r payload/app/fonts  $out/share/pitchnet/
    cp -r payload/app/lang   $out/share/pitchnet/
    chmod -R u+w $out/share/pitchnet

    # VST3 (структура bundle не изменилась)
    mkdir -p $out/lib/vst3
    cp -r payload/vst3/PitchNet.vst3 $out/lib/vst3/
    chmod -R u+w $out/lib/vst3/PitchNet.vst3

    runHook postInstall
  '';

  meta = with lib; {
    description = "PitchNet – neural pitch correction plugin (VST3 only)";
    homepage = "https://github.com/SessionLoops/PitchNet";
    license = licenses.agpl3Only;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ sourceTypes.binaryNativeCode ];
  };
})
