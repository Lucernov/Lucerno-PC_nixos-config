{ lib
, stdenv
, fetchurl
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

  # Берем файл напрямую с GitHub Media (LFS-домен)
  src = fetchurl {
    url = "https://media.githubusercontent.com/media/Lucernov/Lucerno-PC_nixos-config/main/dotfiles/repo/OT_P1ANO_S.so.xz";
    hash = "sha256-gm7hQYkKYzpSDnr5x0sRd0+i+yNFeNGYpyjj3hM96yw=";
  };

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
    homepage = "https://musictop69.wixsite.com/orchestools";
    license = licenses.gpl3Only;
    platforms = [ "x86_64-linux" ];
  };
}
