# pkgs/pkg_krita-vision-tools.nix
#
# Плагин Krita Vision Tools (v2.1.0) — ML-инструменты выделения объектов
# и удаления фона (MobileSAM, BiRefNet, MI-GAN).
#
# ВАЖНО: v2.1.0 — последняя версия для Krita 5.2 (Qt5/PyQt5).
# v2.2.0 требует Krita 5.3, v3.0.0 — Krita 6.
#
# Патчинг:
#   ggml-*.so и libvisioncpp.so требуют rpath на соседние .so и системные
#   libvulkan.so.1 / libgomp.so.1. Без autoPatchelfHook ggml-vulkan.so
#   не загружается — Vulkan-бэкенд выключен, всё работает на CPU.
#
#   kritavisionml.so линкуется с внутренними библиотеками Krita
#   (libkritaui.so.19 и т.п.) и Qt5/KF5 — их нет в nixpkgs, подтягиваются
#   через dlopen из процесса Krita. Их игнорируем через
#   autoPatchelfIgnoreMissingDeps.

{ lib
, stdenv
, fetchzip
, autoPatchelfHook
, gcc
, vulkan-loader
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "krita-vision-tools";
  version = "2.1.0";

  src = fetchzip {
    url = "https://github.com/Acly/krita-vision-tools/releases/download/v${finalAttrs.version}/krita_vision_tools-linux-x64-${finalAttrs.version}.zip";
    hash = "sha256-pYSxLegmp2uT2pW+sLoNNKKPc7bKJI8D5tBDqAUwynQ=";
    stripRoot = false;
  };

  nativeBuildInputs = [ autoPatchelfHook ];

  buildInputs = [
    gcc.cc.lib        # libstdc++.so.6, libgomp.so.1
    vulkan-loader     # libvulkan.so.1
  ];

  # Внутренние библиотеки Krita и Qt/KF5, которые подгружаются dlopen-ом
  # из процесса Krita — их нет отдельными пакетами в nixpkgs.
  autoPatchelfIgnoreMissingDeps = [
    "libkritaui.so.19"
    "libkritaimage.so.19"
    "libkritaflake.so.19"
    "libkritapigment.so.19"
    "libkritacommand.so.19"
    "libkritawidgetutils.so.19"
    "libkritaresources.so.19"
    "libkritaglobal.so.19"
    "libKF5CoreAddons.so.5"
    "libKF5I18n.so.5"
    "libKF5ConfigCore.so.5"
    "libQt5Widgets.so.5"
    "libQt5Gui.so.5"
    "libQt5Core.so.5"
  ];

  dontConfigure = true;
  dontBuild = true;
  dontPatch = true;
  dontStrip = true;
  # dontFixup убран намеренно: autoPatchelfHook должен отработать.

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/krita/pykrita
    cp -r vision_tools       $out/share/krita/pykrita/
    cp vision_tools.desktop  $out/share/krita/pykrita/
    runHook postInstall
  '';

  meta = with lib; {
    description = "Krita plugin for ML-based object selection and background removal";
    homepage = "https://github.com/Acly/krita-vision-tools";
    license = licenses.gpl3Only;
    platforms = [ "x86_64-linux" ];
  };
})
