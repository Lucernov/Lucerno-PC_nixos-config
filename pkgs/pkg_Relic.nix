# pkgs/pkg_Relic.nix
#
# Relic Free Audio Plugin Suite — набор из 13 бесплатных CLAP-плагинов
# (эмуляции классических компрессоров, эквалайзеров и предусилителей).
#
# Особенности:
#   - Только CLAP-формат (VST3 отброшен как дубликат — те же плагины).
#   - Зависимости минимальны: fontconfig, freetype, libstdc++.
#     Всё остальное (gtk, X11, glib) статически вкомпилировано в .clap.
#   - Архив изначально .zip (275 МБ), пересобран в tar.zst (92 МБ),
#     хранится в dotfiles/repo/ через Git LFS.

{ lib
, stdenv
, autoPatchelfHook
, fontconfig
, freetype
, zstd
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "relic-clap";
  version = "0.3.1";

  src = ../dotfiles/repo/Relic-Linux-CLAP-0.3.1.tar.zst;

  nativeBuildInputs = [ autoPatchelfHook zstd ];

  buildInputs = [
    fontconfig
    freetype
    stdenv.cc.cc.lib
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/clap
    cp *.clap $out/lib/clap/

    runHook postInstall
  '';

  meta = with lib; {
    description = "Relic Free Audio Plugin Suite — 13 CLAP plugins";
    homepage = "https://github.com/RelicFreeAudio/relic";
    license = licenses.gpl3Only;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ sourceTypes.binaryNativeCode ];
  };
})
