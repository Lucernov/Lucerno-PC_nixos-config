{ lib, stdenv, autoPatchelfHook, alsa-lib, freetype, libGL, glib, gtk3, libX11, libXext, libXrender, libXcursor, libXfixes, libXi, libXrandr, libxcb, libxkbcommon, xcbutil, xcbutilcursor, ... }:

stdenv.mkDerivation {
  pname = "ot-piano-s";
  version = "1.0";

  src = ../dotfiles/repo/OT_P1ANO_S.so;

  nativeBuildInputs = [ autoPatchelfHook ];

  buildInputs = [
    alsa-lib
    freetype
    libGL
    glib
    gtk3
    libX11
    libXext
    libXrender
    libXcursor
    libXfixes
    libXi
    libXrandr
    libxcb
    libxkbcommon
    xcbutil
    xcbutilcursor
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
