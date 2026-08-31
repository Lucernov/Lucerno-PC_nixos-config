{ lib
, stdenv
, autoPatchelfHook
, alsa-lib
, freetype
, libX11
, libXext
, libxcb
, libGL
, versions
}:

let
  version = versions.air-g-plugins;
in

stdenv.mkDerivation {
  pname = "air-g-plugins";
  inherit version;

  src = ../dotfiles/repo/Air-G-Plugins-Collection.tar.xz;

  nativeBuildInputs = [ autoPatchelfHook ];

  buildInputs = [
    alsa-lib
    freetype
    libX11
    libXext
    libxcb
    libGL
    stdenv.cc.cc.lib
  ];

  unpackPhase = ''
    tar -xf $src
  '';

  installPhase = ''
    mkdir -p $out/lib/vst3
    cp -r ./Air-G\ Plugins\ Collection\ -\ LINUX\ NO\ INSTALLER/*.vst3 $out/lib/vst3/
  '';

  meta = with lib; {
    description = "Air-G Plugins Collection (VST3)";
    homepage = "https://www.airmusictech.com/";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
  };
}
