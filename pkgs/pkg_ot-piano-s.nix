{ lib
, stdenv
, xz
, autoPatchelfHook
, alsa-lib
, freetype
, libX11
, libXext
, libxcb
, versions
}:

let
  version = versions.ot-piano-s.version;
in

stdenv.mkDerivation {
  pname = "ot-piano-s";
  inherit version;

  src = ../dotfiles/repo/OT_P1ANO_S.so.xz;

  nativeBuildInputs = [ xz autoPatchelfHook ];

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
    runHook preInstall
    mkdir -p $out/lib/vst
    xz -d -c $src > $out/lib/vst/OT_P1ANO_S.so
    runHook postInstall
  '';

  meta = with lib; {
    description = "Orchestools Piano S – VST2 plugin";
    homepage = "https://github.com/Lucernov/Lucerno-PC_nixos-config";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
  };
}
