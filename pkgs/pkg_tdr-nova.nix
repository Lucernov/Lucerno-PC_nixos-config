# pkgs/pkg_tdr-nova.nix
#
# TDR Nova — параллельный динамический эквалайзер от Tokyo Dawn Labs.
# Нативная Linux-сборка (x86_64): VST2 + VST3, без CLAP.
#
# Зависимости определены через readelf -d (NEEDED) и strings (dlopen):
#   NEEDED:  libasound, libX11, libXinerama, libXext, libfreetype,
#            librt, libdl, libpthread, libm, libc, libstdc++, libgcc_s
#   dlopen:  libcurl, libXcursor, libXrandr, libXss
#
# dlopen-библиотеки autoPatchelfHook не видит (их нет в NEEDED).
# runtimeDependencies в используемой версии auto-patchelf (0-unstable-2024-08-14)
# резолвит NEEDED, но в RPATH не добавляет — проверено patchelf --print-rpath:
# в RPATH попадают только 7 путей из NEEDED, без curl/Xcursor/Xrandr/Xss.
# Поэтому используем appendRunpaths — он добавляет пути ПОСЛЕ shrink-rpath,
# из-за чего они не вырезаются (тот же приём, что в pkg_tal-vocoder-2.nix
# для $ORIGIN и libTAL-Vocoder-2.so).
#
# lib.getLib curl: у curl libcurl.so.4 лежит в output `out`, а не `bin`.
# Без getLib в RPATH попадёт curl-<ver>-bin/lib, где libcurl.so.4 нет —
# dlopen("libcurl.so.4") упадёт молча.
#
# libGL и libxcb не требуются — плагин не использует OpenGL и не грузит
# xcb напрямую.
#
# URL — прямая ссылка с сайта Tokyo Dawn Labs. Формат:
#   https://www.tokyodawn.net/labs/Nova/<version>/TDR%20Nova.tar.gz
# При выходе новой версии — поменять version и hash (см. ниже).
# Обновление вручную: скачать архив, пересчитать хеш
#   nix hash file --sri --type sha256 "TDR Nova.tar.gz"

{ lib
, stdenv
, fetchurl
, autoPatchelfHook
, alsa-lib
, freetype
, libX11
, libXext
, libXinerama
, libXcursor
, libXrandr
, libXScrnSaver
, curl
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "tdr-nova";
  version = "2.2.3";

  src = fetchurl {
    # Версия продублирована в URL явно (не через ${finalAttrs.version}),
    # чтобы было видно при ручном обновлении, что именно менять.
    url = "https://www.tokyodawn.net/labs/Nova/2.2.3/TDR%20Nova.tar.gz";
    hash = "sha256-AOk7cITyPdmSpl+qwxr4qmLQ4CpmWgbwnUVscPatNT8=";
  };

  nativeBuildInputs = [ autoPatchelfHook ];

  buildInputs = [
    alsa-lib
    freetype
    libX11
    libXext
    libXinerama
    stdenv.cc.cc.lib                                              # libstdc++.so.6, libgcc_s.so.1
  ];

  # dlopen-зависимости: не попадают в NEEDED, хук их не видит.
  # appendRunpaths добавляет пути в RPATH после shrink-rpath,
  # поэтому они не вырезаются (см. комментарий в шапке файла).
  appendRunpaths = map (p: "${lib.getLib p}/lib") [
    curl
    libXcursor
    libXrandr
    libXScrnSaver
  ];

  # Архив распаковывается «как есть» — все файлы в корне.
  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    # VST2 — одиночный .so в корне архива
    mkdir -p $out/lib/vst
    cp "TDR Nova.so" "$out/lib/vst/TDR Nova.so"

    # VST3 — бандл (папка с Contents/)
    mkdir -p $out/lib/vst3
    cp -r "TDR Nova.vst3" "$out/lib/vst3/"

    # Документация (.asc-подписи не нужны)
    mkdir -p $out/share/doc/tdr-nova
    cp license.txt changelog.txt README $out/share/doc/tdr-nova/

    # Убираем detached GPG-подписи из store — они не нужны в рантайме
    rm -f "$out/lib/vst/TDR Nova.so.asc"
    find "$out/lib/vst3" -name '*.asc' -delete

    runHook postInstall
  '';

  meta = with lib; {
    description = "TDR Nova — parallel dynamic equalizer by Tokyo Dawn Labs (VST2 + VST3)";
    homepage = "https://www.tokyodawn.net/tdr-nova/";
    license = licenses.unfree;                                    # Freeware, но проприетарная
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ sourceTypes.binaryNativeCode ];
  };
})
