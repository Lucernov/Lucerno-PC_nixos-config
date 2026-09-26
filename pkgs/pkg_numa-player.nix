# pkgs/pkg_numa-player.nix
#
# Numa Player — бесплатный виртуальный инструмент от Studiologic (VST3 + standalone).
# Лицензия проприетарная (unfree), но сам плагин бесплатный.
#
# Особенности:
#   - 380 МБ сэмплов (.numalib/.numares) лежат в /usr/lib/Numa Player/ в .deb.
#   - Плагин ищет их по абсолютному пути /usr/lib/Numa Player (через `access()`),
#     относительно себя (../lib/) он их НЕ находит — проверено strace.
#     Поэтому в nx_audio.nix создаётся симлинк /usr/lib/Numa Player → $out/lib/Numa Player.
#   - Пресеты (Factory/, Organs/, User/) создаются самим плагином в
#     ~/Documents/Studiologic/Numa Player/ при первом запуске.
#   - X11-библиотеки подгружаются через dlopen, поэтому используется
#     runtimeDependencies (как в TAL-Vocoder-2).

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

    # Данные — 380 МБ сэмплов (.numalib/.numares)
    mkdir -p "$out/lib/Numa Player"
    cp -r "usr/lib/Numa Player/." "$out/lib/Numa Player/"

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

    # .desktop
    mkdir -p $out/share/applications
    cp "usr/share/applications/Numa Player.desktop" $out/share/applications/
    sed -i 's|^Exec=.*|Exec=numa-player|' "$out/share/applications/Numa Player.desktop"
    sed -i 's|^Icon=.*|Icon=NumaPlayer|' "$out/share/applications/Numa Player.desktop"

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
