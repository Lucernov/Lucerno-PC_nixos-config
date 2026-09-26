# pkgs/pkg_tal-vocoder-2.nix
#
# Особенность сборки:
#   Плагин (и CLAP, и VST3) подгружает общую библиотеку libTAL-Vocoder-2.so
#   через dlopen() во время работы, а НЕ через NEEDED-секцию ELF.
#   Это значит, что autoPatchelfHook её «не видит» и не прописывает в rpath.
#
#   Что делаем:
#     1. Кладём libTAL-Vocoder-2.so РЯДОМ с каждым плагином
#        (в одну папку с .clap и в Contents/x86_64-linux/ с .so).
#     2. Через appendRunpaths = [ "$ORIGIN" ] добавляем $ORIGIN в rpath
#        обоих плагинов. $ORIGIN = папка самого бинарника, поэтому
#        dlopen найдёт libTAL по относительному пути, и rpath будет
#        работать даже если store переедет.
#
#   Почему не postFixup с patchelf --add-rpath:
#     autoPatchelfHook после себя вызывает shrink-rpath, который вырезает
#     из rpath всё, что не соответствует NEEDED-зависимостям. $ORIGIN
#     туда не попадает (libTAL не в NEEDED), и он удаляется.
#     appendRunpaths — официальный механизм autoPatchelfHook, который
#     добавляет пути ПОСЛЕ формирования финального rpath.

{ lib
, stdenv
, fetchurl
, unzip
, autoPatchelfHook
, alsa-lib
, freetype
, versions
}:

let
  inherit (versions.tal-vocoder-2) version url hash;
in

stdenv.mkDerivation {
  pname = "tal-vocoder-2";
  inherit version;

  src = fetchurl {
    inherit url hash;
  };

  nativeBuildInputs = [ unzip autoPatchelfHook ];

  buildInputs = [
    alsa-lib
    freetype
    stdenv.cc.cc.lib
  ];

  # libTAL-Vocoder-2.so подгружается через dlopen(), не через NEEDED,
  # поэтому autoPatchelfHook её не видит. appendRunpaths добавляет
  # $ORIGIN в финальный rpath, который auto-patchelf сам прописывает.
  # $ORIGIN = папка самого плагина → dlopen найдёт libTAL рядом.
  appendRunpaths = [ "$ORIGIN" ];

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    # CLAP + lib рядом
    mkdir -p $out/lib/clap
    cp TAL-Vocoder-2/TAL-Vocoder-2.clap $out/lib/clap/
    cp TAL-Vocoder-2/libTAL-Vocoder-2.so $out/lib/clap/

    # VST3 + lib рядом
    mkdir -p $out/lib/vst3/TAL-Vocoder-2.vst3/Contents/x86_64-linux
    cp TAL-Vocoder-2/TAL-Vocoder-2.vst3/Contents/x86_64-linux/TAL-Vocoder-2.so \
      $out/lib/vst3/TAL-Vocoder-2.vst3/Contents/x86_64-linux/
    cp TAL-Vocoder-2/libTAL-Vocoder-2.so \
      $out/lib/vst3/TAL-Vocoder-2.vst3/Contents/x86_64-linux/

    # Документация
    mkdir -p $out/share/doc/tal-vocoder-2
    cp TAL-Vocoder-2/ReadmeLinux.txt $out/share/doc/tal-vocoder-2/

    runHook postInstall
  '';

  meta = with lib; {
    description = "TAL-Vocoder-2 — vintage-style vocoder plugin (VST3 + CLAP)";
    homepage = "https://tal-software.com/products/tal-vocoder";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ sourceTypes.binaryNativeCode ];
  };
}
