# pkgs/pkg_Amp-Locker.nix
#
# Amp Locker от Audio Assault (VST3 + LV2).
#
# Standalone НЕ устанавливается: бинарник падает с SEGV в
# juce::StandaloneFilterWindow::StandaloneFilterWindow (баг JUCE на Linux,
# тот же, что у PitchNet). VST3/LV2 в REAPER работают нормально.

{ lib
, stdenv
, fetchurl
, unzip
, autoPatchelfHook
, alsa-lib
, freetype
, curl
, versions
}:

let
  inherit (versions.amp-locker) version url hash;
in

stdenv.mkDerivation {
  pname = "amp-locker";
  inherit version;

  src = fetchurl {
    inherit url hash;
  };

  nativeBuildInputs = [ unzip autoPatchelfHook ];

  buildInputs = [
    alsa-lib
    freetype
    curl
    stdenv.cc.cc.lib
  ];

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    # VST3
    mkdir -p $out/lib/vst3
    cp -r "Amp Locker.vst3" $out/lib/vst3/

    # LV2
    mkdir -p $out/lib/lv2
    cp -r "Amp Locker.lv2" $out/lib/lv2/

    # Данные (пресеты, импульсы)
    mkdir -p $out/share/amp-locker
    cp -r AmpLockerData/* $out/share/amp-locker/

    # Standalone НЕ копируем — падает при старте из-за бага JUCE.
    # VST3/LV2 в REAPER работают нормально.

    runHook postInstall
  '';

  meta = with lib; {
    description = "Guitar amp simulator by Audio Assault (VST3 + LV2)";
    homepage = "https://audioassault.mx/amplocker";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ sourceTypes.binaryNativeCode ];
  };
}
