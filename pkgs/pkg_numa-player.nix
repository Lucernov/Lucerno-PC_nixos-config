# pkgs/pkg_numa-player.nix
#
# Numa Player — бесплатный виртуальный инструмент от Studiologic (VST3 + standalone).
# Лицензия проприетарная (unfree), но сам плагин бесплатный.
#
# Особенности:
#   - В .deb лежат данные (.numalib/.numares, ~380 МБ), но мы их НЕ копируем.
#     Плагин сам скачивает нужные библиотеки в ~/.config/Studiologic/Numa Player/
#     при первом использовании. Проверено: работает без данных из .deb.
#     В store остаются только бинарники (VST3 + standalone).
#   - Пресеты (Factory/, Organs/, User/) плагин создаёт сам в
#     ~/Documents/Studiologic/Numa Player/ при первом запуске.
#   - X11-библиотеки подгружаются через dlopen → runtimeDependencies.
#   - Standalone оборачивается makeWrapper с АБСОЛЮТНЫМ путём к бинарнику
#     ($out/libexec/numa-player/Numa Player), иначе обёртка запоминает
#     относительный путь и ломается при запуске из другого cwd.
#   - Categories=AudioVideo;... в .desktop — иначе KDE кладёт в «Прочее».

{ lib
, stdenv
, fetchurl
, dpkg
, autoPatchelfHook
, makeWrapper
, alsa-lib
, freetype
, fontconfig
, curl
, libX11
, libXcursor
, libXext
, libXinerama
, libXrandr
, versions
}:

let
  inherit (versions.numa-player) version url hash;
in

stdenv.mkDerivation {
  pname = "numa-player";
  inherit version;

  src = fetchurl {
    inherit url hash;
  };

  nativeBuildInputs = [ dpkg autoPatchelfHook makeWrapper ];

  buildInputs = [
    alsa-lib
    freetype
    fontconfig
    curl
    stdenv.cc.cc.lib
  ];

  # X11-библиотеки подгружаются через dlopen, их нет в NEEDED.
  # runtimeDependencies добавляет их пути в rpath принудительно.
  runtimeDependencies = [
    libX11
    libXcursor
    libXext
    libXinerama
    libXrandr
  ];

  unpackPhase = ''
    runHook preUnpack
    dpkg-deb -x $src .
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    # VST3
    mkdir -p $out/lib/vst3
    cp -r "usr/lib/vst3/Numa Player.vst3" $out/lib/vst3/

    # Данные (.numalib/.numares) НЕ копируем — 380 МБ балласта.
    # Плагин сам скачивает нужные библиотеки в ~/.config/Studiologic/Numa Player/Libraries/
    # при первом использовании. Проверено: работает без этих данных.

    # Standalone — сначала копируем в $out/libexec, затем оборачиваем.
    # ВАЖНО: путь к бинарнику в makeWrapper должен быть абсолютным ($out/...),
    # иначе обёртка запомнит относительный путь и сломается при запуске
    # из любого другого cwd.
    mkdir -p $out/libexec/numa-player
    cp "usr/bin/Numa Player" "$out/libexec/numa-player/Numa Player"
    chmod +x "$out/libexec/numa-player/Numa Player"

    mkdir -p $out/bin
    makeWrapper "$out/libexec/numa-player/Numa Player" $out/bin/numa-player \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [
        alsa-lib freetype fontconfig curl
        libX11 libXcursor libXext libXinerama libXrandr
        stdenv.cc.cc.lib
      ]}"

    # .desktop — копируем под именем без пробела (KDE не любит пробелы)
    mkdir -p $out/share/applications
    cp "usr/share/applications/Numa Player.desktop" \
       "$out/share/applications/numa-player.desktop"

    sed -i \
      -e 's|^Exec=.*|Exec=numa-player|' \
      -e 's|^Icon=.*|Icon=NumaPlayer|' \
      "$out/share/applications/numa-player.desktop"

    # Categories — иначе KDE кладёт в «Прочее».
    # AudioVideo первой → раздел «Мультимедиа → Аудио и музыка».
    if grep -q '^Categories=' "$out/share/applications/numa-player.desktop"; then
      sed -i 's|^Categories=.*|Categories=AudioVideo;Audio;Music;|' \
        "$out/share/applications/numa-player.desktop"
    else
      echo 'Categories=AudioVideo;Audio;Music;' >> \
        "$out/share/applications/numa-player.desktop"
    fi

    # Иконка
    mkdir -p $out/share/icons/hicolor/256x256/apps
    cp "usr/share/icons/hicolor/256x256/apps/NumaPlayer.png" \
       $out/share/icons/hicolor/256x256/apps/

    runHook postInstall
  '';

  meta = with lib; {
    description = "Numa Player — виртуальный инструмент от Studiologic (VST3 + standalone)";
    homepage = "https://www.studiologic-music.com/products/numaplayer/";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ sourceTypes.binaryNativeCode ];
  };
}
