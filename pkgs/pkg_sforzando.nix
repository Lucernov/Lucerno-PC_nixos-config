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
, makeWrapper
, glib
, cairo
, pango
, fontconfig
, curl
, libxkbcommon
, libpulseaudio
, gtk3
, gtkmm3
, glibmm
, libsigcxx
, libxcb-util
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

  nativeBuildInputs = [ unzip dpkg autoPatchelfHook makeWrapper ];

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
    libxcb-util
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

    # Копируем все ресурсы в share
    mkdir -p $out/share/plogue-sforzando
    cp -r extracted/opt/Plogue/* $out/share/plogue-sforzando/

    # Копируем VST3 и CLAP
    mkdir -p $out/lib/vst3
    cp -r extracted/usr/lib/vst3/* $out/lib/vst3/ || true

    mkdir -p $out/lib/clap
    cp -r extracted/usr/lib/clap/* $out/lib/clap/ || true

    # Создаём обёртку для исполняемого файла с добавлением PATH для zenity
    mkdir -p $out/bin
    makeWrapper $out/share/plogue-sforzando/sforzando/sforzando $out/bin/sforzando \
      --set QT_QPA_PLATFORM xcb \
      --set GDK_BACKEND x11 \
      --suffix PATH : /run/current-system/sw/bin \
      --set DBUS_SESSION_BUS_ADDRESS "unix:path=/run/user/1000/bus" \
      --chdir $out/share/plogue-sforzando/sforzando

    # Копируем .desktop, иконки, документацию
    mkdir -p $out/share
    cp -r extracted/usr/share/applications $out/share/ || true
    cp -r extracted/usr/share/icons $out/share/ || true
    cp -r extracted/usr/share/doc $out/share/ || true

    # Исправляем .desktop
    if [ -f $out/share/applications/plogue-sforzando.desktop ]; then
      sed -i 's|Exec=/opt/Plogue/sforzando/sforzando|Exec=sforzando|g' $out/share/applications/plogue-sforzando.desktop
    fi

    # Создаём симлинк для иконки в pixmaps
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
