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
, libGL
, versions
}:

let
  version = versions.orchestools.version;
in

stdenv.mkDerivation {
  pname = "orchestools";
  inherit version;

  # Берем все 4 архива с GitHub Media (LFS-домен)
  srcs = [
    (fetchurl {
      url = "https://media.githubusercontent.com/media/Lucernov/Lucerno-PC_nixos-config/main/dotfiles/repo/ORCHESTOOLS-BRASS-1.0.1.tar.xz";
      hash = "sha256-8mbhpkr50nvIauLRok5J1ismLKUVtfBiZ0CTAFg/pxI=";
    })
    (fetchurl {
      url = "https://media.githubusercontent.com/media/Lucernov/Lucerno-PC_nixos-config/main/dotfiles/repo/ORCHESTOOLS-PERC-1.0.1.tar.xz";
      hash = "sha256-DULO+9KEawYPyxmIRy0foQJbe+O+Ghn4keqAhagpdAk=";
    })
    (fetchurl {
      url = "https://media.githubusercontent.com/media/Lucernov/Lucerno-PC_nixos-config/main/dotfiles/repo/ORCHESTOOLS-STRINGS-1.0.2.tar.xz";
      hash = "sha256-mOam9o7336YMrwbUoyZZAASZ8+QJZfxaDOP6q1jmZos=";
    })
    (fetchurl {
      url = "https://media.githubusercontent.com/media/Lucernov/Lucerno-PC_nixos-config/main/dotfiles/repo/ORCHESTOOLS-WINDS-1.0.0.tar.xz";
      hash = "sha256-tEnQvbvB/sysKMTuIPUVbOGp9X8X4LU/o9zoYUJK0rI=";
    })
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
    homepage = "https://musictop69.wixsite.com/orchestools/orchestools-two";
    license = licenses.gpl3Only;
    platforms = [ "x86_64-linux" ];
  };
}
