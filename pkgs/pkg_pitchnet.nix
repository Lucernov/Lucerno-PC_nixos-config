# pkgs/pkg_pitchnet.nix
#
# Особенности:
#   - PitchNet распространяется как Makeself-архив (.run), не tar/zip.
#     Распаковываем через `sh $src --noexec --target .` — распаковка без
#     запуска install.sh (который требует root и ставит в /opt).
#   - libonnxruntime.so.1 и libonnxruntime_providers_shared.so лежат в
#     payload/opt/Session Loops/PitchNet/lib/ — разработчик поставляет
#     их как бандл внутри .run, а не как системную зависимость.
#     Мы копируем эту папку в $out/share/pitchnet/lib/, поэтому
#     autoPatchelfHook (рекурсивно обходит $out) находит их сам и
#     прописывает путь в rpath VST3. В логе сборки это видно:
#       libonnxruntime.so.1 -> found: .../share/pitchnet/lib
#   - autoPatchelfIgnoreMissingDeps — страховка: если по какой-то причине
#     autoPatchelfHook не найдёт onnxruntime в $out (например, апстрим
#     изменит структуру .run), сборка не упадёт, а пропустит эти deps.
#     На практике он их находит, поэтому эта опция не срабатывает.
#   - Standalone НЕ устанавливается: падает при старте с SEGV в
#     juce::Component::centreWithSize (баг JUCE на Linux). VST3 в REAPER
#     работает нормально.

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
  version = "0.7.1";

  src = fetchurl {
    # Обрати внимание: в URL стоит "v${version}" — GitHub-тег начинается с v,
    # а версия в файле — без него. nix-update понимает это автоматически.
    url = "https://github.com/SessionLoops/PitchNet/releases/download/v${finalAttrs.version}/PitchNet-Linux-x86_64.run";
    hash = "sha256-voKEko7kqYyrUGdpGJ9r+P+VORPg/3u2gjulMb21tac=";
  };

  nativeBuildInputs = [ autoPatchelfHook ];

  buildInputs = [
    alsa-lib
    freetype
    fontconfig
    stdenv.cc.cc.lib
  ];

  # Страховка: если autoPatchelfHook не найдёт onnxruntime в $out,
  # сборка не упадёт. См. комментарий в шапке файла.
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

    # Ресурсы, нужные VST3-плагину: модели, libonnxruntime, шрифты, локали.
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

  meta = with lib; {
    description = "PitchNet – neural pitch correction plugin (VST3 only)";
    homepage = "https://github.com/SessionLoops/PitchNet";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ sourceTypes.binaryNativeCode ];
  };
})
