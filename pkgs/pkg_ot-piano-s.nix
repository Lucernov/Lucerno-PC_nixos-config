{ lib, stdenv, autoPatchelfHook, alsa-lib, freetype, libX11, libXext, libxcb }:

stdenv.mkDerivation {
  pname = "ot-piano-s";
  version = "1.0";

  src = ../dotfiles/repo/OT_P1ANO_S.so;

  nativeBuildInputs = [ autoPatchelfHook ];

  buildInputs = [
    alsa-lib
    freetype
    libX11
    libXext
    libxcb
    stdenv.cc.cc.lib
  ];

  dontUnpack = true;

  installPhase = ''
    mkdir -p $out/lib/vst
    cp $src $out/lib/vst/OT_P1ANO_S.so
  '';

  meta = with lib; {
    description = "Orchestools Piano S – VST2 plugin";
    homepage = "https://github.com/Lucernov/Lucerno-PC_nixos-config";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
  };
}
