{ lib
, stdenv
, fetchurl
, autoPatchelfHook
, alsa-lib
, freetype
, libX11
, libXext
, libxcb
, libGL
, zstd
, versions
}:

let
  version = versions.air-g-plugins.version;
in

stdenv.mkDerivation {
  pname = "air-g-plugins";
  inherit version;

  # Архив берётся из GitHub Releases
  src = fetchurl {
    url = "https://github.com/Lucernov/Lucerno-PC_nixos-config/releases/download/air-g-1.0/Air-G-Plugins-Collection.tar.zst";
    hash = "sha256-4ZI017GwKY6O91m4U0HBUfGf8OMAiEZWJ8HBS6cPioc=";
  };

  nativeBuildInputs = [ autoPatchelfHook zstd ];

  buildInputs = [
    alsa-lib
    freetype
    libX11
    libXext
    libxcb
    libGL
    stdenv.cc.cc.lib
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib/vst3
    cp -r ./*.vst3 $out/lib/vst3/
    runHook postInstall
  '';

  meta = with lib; {
    description = "Air-G Plugins Collection (VST3)";
    homepage = "https://ko-fi.com/airgaudio/shop/";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
  };
}
