{ lib
, stdenv
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

  src = ../dotfiles/repo/Air-G-Plugins-Collection.tar.zst;

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
    homepage = "https://www.airmusictech.com/";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
  };
}
