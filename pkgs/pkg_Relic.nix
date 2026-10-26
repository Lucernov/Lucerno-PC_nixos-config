# pkgs/pkg_Relic.nix
#
# Relic Free Audio Plugin Suite — набор из 13 бесплатных CLAP-плагинов
# (эмуляции классических компрессоров, эквалайзеров и предусилителей).
#
# Особенности:
#   - Только CLAP-формат (VST3 отброшен как дубликат — те же плагины).
#   - Зависимости минимальны: fontconfig, freetype, libstdc++.
#     Всё остальное (gtk, X11, glib) статически вкомпилировано в .clap.
#   - Архив изначально .zip (~500 МБ), пересобран в tar.zst (~122 МБ)
#     с максимальным сжатием (zstd --ultra -22), хранится в dotfiles/repo/
#     через Git LFS.

{ lib
, stdenv
, fetchurl
, autoPatchelfHook
, fontconfig
, freetype
, zstd
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "relic-clap";
  version = "0.4.3";

  # Архив берётся из GitHub Releases (ассет релиза relic-clap-<version>).
  # Не расходует LFS-квоту и не зависит от media CDN — прямые ссылки на S3 через release-assets.githubusercontent.com.
  src = fetchurl {
    url = "https://github.com/Lucernov/Lucerno-PC_nixos-config/releases/download/relic-clap-0.4.3/Relic-Linux-CLAP-0.4.3.tar.zst";
    hash = "sha256-YMdyHSjsgeW4Wd2aNf99LFlkbaPX9qXMAy0fcD5jGUI=";
  };

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
    homepage = "https://riverfluxaudio.gumroad.com/l/Relic";
    license = licenses.unfreeRedistributable;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ sourceTypes.binaryNativeCode ];
  };
})
