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
, unzip
, dpkg
, glib
, cairo
, pango
, fontconfig
, curl
, xcbutil
, libxkbcommon
, libpulseaudio
, gtk3
, gtkmm3
, glibmm
, libsigcxx
, versions
}:

let
  version = versions.sforzando;
in

stdenv.mkDerivation {
  pname = "sforzando";
  inherit version;

  src = fetchurl {
    url = "https://sforzando.s3.us-east-1.amazonaws.com/LINUX_plogue-sforzando_${version}_x86_64.zip";
    hash = "sha256-7ms1T9N1/50M4wgZaD9E07cSof5P9Tx35E3wNtqCqQA=";
  };

  nativeBuildInputs = [ unzip dpkg autoPatchelfHook ];

  buildInputs = [
    alsa-lib
    freetype
    libX11
    libXext
    libxcb
    libGL
    stdenv.cc.cc.lib
    glib
    cairo
    pango
    fontconfig
    curl
    xcbutil
    libxkbcommon
    libpulseaudio
    gtk3
    gtkmm3
    glibmm
    libsigcxx
  ];

  unpackPhase = ''
    runHook preUnpack
    unzip $src
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    cd LINUX_plogue-sforzando_${version}_x86_64

    mkdir -p extracted
    for deb in *.deb; do
      dpkg-deb -x "$deb" extracted
    done

    mkdir -p $out/opt
    cp -r extracted/opt/Plogue $out/opt/

    mkdir -p $out/lib/vst3
    cp -r extracted/usr/lib/vst3/* $out/lib/vst3/ || true

    mkdir -p $out/lib/clap
    cp -r extracted/usr/lib/clap/* $out/lib/clap/ || true

    mkdir -p $out/bin
    chmod +x $out/opt/Plogue/sforzando/sforzando
    ln -s $out/opt/Plogue/sforzando/sforzando $out/bin/sforzando

    mkdir -p $out/share
    cp -r extracted/usr/share/applications $out/share/ || true
    cp -r extracted/usr/share/icons $out/share/ || true
    cp -r extracted/usr/share/doc $out/share/ || true

    # Исправляем .desktop файл – меняем путь к исполняемому файлу
    if [ -f $out/share/applications/plogue-sforzando.desktop ]; then
      sed -i 's|Exec=/opt/Plogue/sforzando/sforzando|Exec=sforzando|g' $out/share/applications/plogue-sforzando.desktop
    fi

    # Создаём симлинк для иконки в pixmaps (чтобы .desktop нашёл её)
    mkdir -p $out/share/pixmaps
    if [ -f $out/share/icons/hicolor/256x256/apps/plogue-sforzando.png ]; then
      ln -s $out/share/icons/hicolor/256x256/apps/plogue-sforzando.png $out/share/pixmaps/plogue-sforzando.png
    fi

    runHook postInstall
  '';

  meta = with lib; {
    description = "Free SFZ 2.0 compliant sample player by Plogue";
    homepage = "https://www.plogue.com/products/sforzando.html";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ sourceTypes.binaryNativeCode ];
    maintainers = [ ];
  };
}
