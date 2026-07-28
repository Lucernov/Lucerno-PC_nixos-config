{ lib
, stdenv
, fetchurl
, unzip
, autoPatchelfHook
, makeWrapper
, alsa-lib
, freetype
, curl
}:

stdenv.mkDerivation {
  pname = "drum-locker";
  version = "1.0.2";

  src = fetchurl {
    url = "https://audioassaultdownloads.s3.amazonaws.com/AmpLocker/AmpLocker109/DrumLockerLinux.zip";
    hash = "sha256-fX6k5C64wNlHK1QsrdClitWlFR33jymEdVO7QIVFNGs=";
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
