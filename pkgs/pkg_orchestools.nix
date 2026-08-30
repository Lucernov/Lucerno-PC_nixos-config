{ lib
, stdenv
, xz
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
  version = versions.orchestools;
in

stdenv.mkDerivation {
  pname = "orchestools";
  inherit version;

  srcs = [
    ../dotfiles/repo/ORCHESTOOLS-BRASS-1.0.1.tar.xz
    ../dotfiles/repo/ORCHESTOOLS-PERC-1.0.1.tar.xz
    ../dotfiles/repo/ORCHESTOOLS-STRINGS-1.0.2.tar.xz
    ../dotfiles/repo/ORCHESTOOLS-WINDS-1.0.0.tar.xz
  ];

  nativeBuildInputs = [ xz autoPatchelfHook ];

  buildInputs = [
    alsa-lib
    freetype
    libX11
    libXext
    libxcb
    libGL
    stdenv.cc.cc.lib
  ];

  dontUnpack = true;

  installPhase = ''
    mkdir -p $out/lib/vst3

    for src in $srcs; do
      tmp=$(mktemp -d)
      tar -xf "$src" -C "$tmp"
      find "$tmp" -maxdepth 2 -type d -name "*.vst3" -exec cp -r {} $out/lib/vst3/ \;
      rm -rf "$tmp"
    done

    # Удаляем возможные мусорные папки (например, __MACOSX)
    rm -rf $out/lib/vst3/__MACOSX 2>/dev/null || true
  '';

  meta = with lib; {
    description = "Orchestools VST3 plugins (Brass, Perc, Strings, Winds)";
    homepage = "https://github.com/Lucernov/Lucerno-PC_nixos-config";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
  };
}
