# pkgs/pkg_music-pattern-generator.nix
#
# Music Pattern Generator — визуальный MIDI-секвенсор на NW.js.
# Распространяется как .deb (Architecture: all).
# Распаковываем через dpkg-deb, патчим ELF-бинарники autoPatchelfHook
# и создаём обёртку mpg с правильным LD_LIBRARY_PATH.

{ lib
, stdenv
, fetchurl
, dpkg
, autoPatchelfHook
, makeWrapper
, alsa-lib
, libX11
, libXext
, libxcb
, libXcomposite
, libXdamage
, libXfixes
, libXrandr
, libXcursor
, libXi
, libXrender
, libXtst
, libXScrnSaver
, gtk3
, glib
, nss
, nspr
, cups
, dbus
, expat
, fontconfig
, freetype
, libdrm
, mesa
, pango
, cairo
, atk
, at-spi2-atk
, at-spi2-core
, libxkbcommon
, libpulseaudio
, versions
}:

let
  inherit (versions.music-pattern-generator) version hash;
in
stdenv.mkDerivation {
  pname = "music-pattern-generator";
  inherit version;

  src = fetchurl {
    url = "https://github.com/hisschemoller/music-pattern-generator/releases/download/v${version}/mpg_2_2_installer_lin.deb";
    inherit hash;
  };

  nativeBuildInputs = [ dpkg autoPatchelfHook makeWrapper ];

  buildInputs = [
    alsa-lib
    libX11
    libXext
    libxcb
    libXcomposite
    libXdamage
    libXfixes
    libXrandr
    libXcursor
    libXi
    libXrender
    libXtst
    libXScrnSaver
    gtk3
    glib
    nss
    nspr
    cups
    dbus
    expat
    fontconfig
    freetype
    libdrm
    mesa
    pango
    cairo
    atk
    at-spi2-atk
    at-spi2-core
    libxkbcommon
    libpulseaudio
    stdenv.cc.cc.lib
  ];

  # .deb — это ar-архив, распаковываем через dpkg-deb
  unpackPhase = ''
    runHook preUnpack
    dpkg-deb -x $src .
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/opt/music-pattern-generator
    cp -r opt/music-pattern-generator/. $out/opt/music-pattern-generator/

    # .desktop-файл
    mkdir -p $out/share/applications
    if [ -f usr/share/applications/music-pattern-generator.desktop ]; then
      cp usr/share/applications/music-pattern-generator.desktop $out/share/applications/
    elif [ -f opt/music-pattern-generator/music-pattern-generator.desktop ]; then
      cp opt/music-pattern-generator/music-pattern-generator.desktop $out/share/applications/
    fi

    # Иконка в pixmaps
    mkdir -p $out/share/pixmaps
    if [ -f opt/music-pattern-generator/img/icon.png ]; then
      cp opt/music-pattern-generator/img/icon.png $out/share/pixmaps/music-pattern-generator.png
    fi

    # Исправляем .desktop: путь /opt/... → mpg (резолвится через PATH)
    if [ -f $out/share/applications/music-pattern-generator.desktop ]; then
      sed -i \
        -e 's|^Exec=.*|Exec=mpg %U|' \
        -e 's|^Icon=.*|Icon=music-pattern-generator|' \
        $out/share/applications/music-pattern-generator.desktop
    fi

    # Обёртка для запуска NW.js
    mkdir -p $out/bin
    makeWrapper $out/opt/music-pattern-generator/nw $out/bin/mpg \
      --chdir "$out/opt/music-pattern-generator" \
      --prefix LD_LIBRARY_PATH : "$out/opt/music-pattern-generator/lib:${lib.makeLibraryPath [
        alsa-lib libX11 libXext libxcb libXcomposite libXdamage libXfixes
        libXrandr libXcursor libXi libXrender libXtst libXScrnSaver
        gtk3 glib nss nspr cups dbus expat fontconfig freetype libdrm mesa
        pango cairo atk at-spi2-atk at-spi2-core libxkbcommon libpulseaudio
        stdenv.cc.cc.lib
      ]}"

    runHook postInstall
  '';

  meta = with lib; {
    description = "Music Pattern Generator – MIDI rhythm pattern generator (NW.js)";
    homepage = "https://github.com/hisschemoller/music-pattern-generator";
    license = licenses.mit;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ sourceTypes.binaryNativeCode ];
    mainProgram = "mpg";
  };
}
