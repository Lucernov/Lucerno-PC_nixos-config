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
  inherit (versions.sforzando) version url hash;
in

stdenv.mkDerivation {
  pname = "sforzando";
  inherit version;

  src = fetchurl {
    inherit url hash;
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
      --run 'export DBUS_SESSION_BUS_ADDRESS="unix:path=$XDG_RUNTIME_DIR/bus"' \
      --chdir $out/share/plogue-sforzando/sforzando

    # Копируем .desktop, иконки, документацию
    mkdir -p $out/share
    cp -r extracted/usr/share/applications $out/share/ || true
    cp -r extracted/usr/share/icons $out/share/ || true
    cp -r extracted/usr/share/doc $out/share/ || true

    # Приводим .desktop к стандартам KDE
    if [ -f $out/share/applications/plogue-sforzando.desktop ]; then
      # Exec — путь /opt/Plogue/... → sforzando (резолвится через PATH)
      sed -i 's|Exec=/opt/Plogue/sforzando/sforzando|Exec=sforzando|g' \
        $out/share/applications/plogue-sforzando.desktop

      # Categories — иначе KDE кладёт в «Прочее»
      if grep -q '^Categories=' $out/share/applications/plogue-sforzando.desktop; then
        sed -i 's|^Categories=.*|Categories=AudioVideo;Audio;Music;|' \
          $out/share/applications/plogue-sforzando.desktop
      else
        echo 'Categories=AudioVideo;Audio;Music;' >> \
          $out/share/applications/plogue-sforzando.desktop
      fi

      # Icon — на всякий случай на имя без пути
      if grep -q '^Icon=' $out/share/applications/plogue-sforzando.desktop; then
        sed -i 's|^Icon=.*|Icon=plogue-sforzando|' \
          $out/share/applications/plogue-sforzando.desktop
      else
        echo 'Icon=plogue-sforzando' >> \
          $out/share/applications/plogue-sforzando.desktop
      fi
    fi

    # Симлинк для иконки в pixmaps (ищем любой формат — png/svg)
    mkdir -p $out/share/pixmaps
    ICON=$(find $out/share/icons -type f -name 'plogue-sforzando.*' 2>/dev/null | head -1)
    if [ -n "$ICON" ]; then
      ln -sf "$ICON" $out/share/pixmaps/plogue-sforzando.png
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
