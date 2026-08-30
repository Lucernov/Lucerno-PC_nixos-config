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
  version = versions.amp-locker;
in

stdenv.mkDerivation {
  pname = "amp-locker";
  inherit version;

  src = fetchurl {
    url = "https://audioassaultdownloads.s3.amazonaws.com/AmpLocker/AmpLocker109/AmpLockerLinux.zip";
    hash = "sha256-fklVvurJoN7TzhwRAnktJm02bMbKmnel6hSIY3QLRxM=";
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

    # Устанавливаем VST3
    mkdir -p $out/lib/vst3
    cp -r "Amp Locker.vst3" $out/lib/vst3/

    # Устанавливаем LV2
    mkdir -p $out/lib/lv2
    cp -r "Amp Locker.lv2" $out/lib/lv2/

    # Устанавливаем данные
    mkdir -p $out/share/amp-locker
    cp -r AmpLockerData/* $out/share/amp-locker/

    # Устанавливаем standalone приложение
    mkdir -p $out/bin
    cp "Amp Locker Standalone" $out/bin/amp-locker-standalone
    chmod +x $out/bin/amp-locker-standalone

    runHook postInstall
  '';

  meta = with lib; {
    description = "Guitar amp simulator by Audio Assault";
    homepage = "https://audioassault.mx/amplocker";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ sourceTypes.binaryNativeCode ];
  };
}
