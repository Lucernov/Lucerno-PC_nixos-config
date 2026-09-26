{ lib
, stdenv
, fetchurl
, makeWrapper
, autoPatchelfHook
, patchelf
, alsa-lib
, freetype
, fontconfig
, versions
}:

let
  inherit (versions.pitchnet) version hash;
in
stdenv.mkDerivation {
  pname = "pitchnet";
  inherit version;

  src = fetchurl {
    url = "https://github.com/SessionLoops/PitchNet/releases/download/v${version}/PitchNet-Linux-x86_64.run";
    inherit hash;
  };

  nativeBuildInputs = [ autoPatchelfHook makeWrapper patchelf ];

  # autoPatchelfHook сам найдёт из этих пакетов libasound, libfontconfig,
  # libfreetype, libstdc++ и пропишет их в rpath обоим бинарникам.
  buildInputs = [
    alsa-lib
    freetype
    fontconfig
    stdenv.cc.cc.lib
  ];

  # libonnxruntime.so.1 — это бандл от разработчика, не из buildInputs.
  # Скажем autoPatchelfHook не ругаться на него.
  autoPatchelfIgnoreMissingDeps = [
    "libonnxruntime.so.1"
    "libonnxruntime_providers_shared.so"
  ];

  # Makeself: распаковываем без запуска install.sh
  unpackPhase = ''
    runHook preUnpack
    sh $src --noexec --target .
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    # Standalone + все ресурсы (fonts, lang, lib, models)
    mkdir -p $out/share/pitchnet
    cp -r "payload/opt/Session Loops/PitchNet/." $out/share/pitchnet/
    chmod -R u+w $out/share/pitchnet
    chmod +x $out/share/pitchnet/PitchNet

    # VST3
    mkdir -p $out/lib/vst3
    cp -r payload/vst3/PitchNet.vst3 $out/lib/vst3/
    chmod -R u+w $out/lib/vst3/PitchNet.vst3

    # .desktop + иконка
    mkdir -p $out/share/applications
    cp payload/usr/share/applications/pitchnet.desktop $out/share/applications/
    mkdir -p $out/share/icons/hicolor/512x512/apps
    cp payload/usr/share/icons/hicolor/512x512/apps/pitchnet.png \
       $out/share/icons/hicolor/512x512/apps/

    sed -i 's|^Exec=.*|Exec=PitchNet|' $out/share/applications/pitchnet.desktop

    # Обёртка для standalone
    mkdir -p $out/bin
    makeWrapper $out/share/pitchnet/PitchNet $out/bin/PitchNet \
      --chdir "$out/share/pitchnet" \
      --set GDK_BACKEND x11 \
      --prefix LD_LIBRARY_PATH : "$out/share/pitchnet/lib"

    runHook postInstall
  '';

  # autoPatchelfHook перезаписал rpath → возвращаем путь к бандлу onnxruntime
  postFixup = ''
    for f in \
      "$out/share/pitchnet/PitchNet" \
      "$out/lib/vst3/PitchNet.vst3/Contents/x86_64-linux/PitchNet.so"
    do
      patchelf --add-rpath "$out/share/pitchnet/lib" "$f"
    done
  '';

  meta = with lib; {
    description = "PitchNet – neural pitch correction plugin (VST3 + standalone)";
    homepage = "https://github.com/SessionLoops/PitchNet";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ sourceTypes.binaryNativeCode ];
    mainProgram = "PitchNet";
  };
}
