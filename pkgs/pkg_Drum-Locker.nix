{ lib
, stdenv
, fetchurl
, unzip
, autoPatchelfHook
, makeWrapper
, alsa-lib
, freetype
, curl
, versions
}:

let
  inherit (versions.drum-locker) version url hash;
in

stdenv.mkDerivation {
  pname = "drum-locker";
  inherit version;

  src = fetchurl {
    inherit url hash;
  };

  nativeBuildInputs = [ unzip autoPatchelfHook makeWrapper ];

  buildInputs = [
    alsa-lib
    freetype
    curl
    stdenv.cc.cc.lib
  ];

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/vst3
    cp -r "Drum Locker.vst3" $out/lib/vst3/

    mkdir -p $out/lib/lv2
    cp -r "Drum Locker.lv2" $out/lib/lv2/

    mkdir -p $out/share/drum-locker
    cp -r DrumLockerData/* $out/share/drum-locker/

    runHook postInstall
  '';

  meta = with lib; {
    description = "Drum sample library player by Audio Assault";
    homepage = "https://audioassault.mx/drumlocker";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ sourceTypes.binaryNativeCode ];
  };
}
