# pkgs/pkg_krita-vision-tools.nix
#
# Плагин Krita Vision Tools (v3.0.0) — ML-инструменты выделения объектов
# и удаления фона (MobileSAM, BiRefNet, MI-GAN).
#
# ВАЖНО: v3.0.0 — официальный релиз для Krita 6 (Qt6). Собран под Krita 6.0.2.1.
# v3.0.0-pre — pre-release, собран под Krita 6.0.1.
# v2.1.0 (для Krita 5.2 / Qt5) больше не подходит.
#
# ВАЖНО про тег релиза:
#   Официальный релиз помечен как v3.0.0, но Linux-архив лежит ТОЛЬКО в теге
#   v3.0.0-pre (в v3.0.0 — только Windows-архив). Оба тега указывают на один
#   и тот же Linux-файл krita_vision_tools-linux-x64-3.0.0.zip.
#   Поэтому URL содержит v3.0.0-pre, а version = "3.0.0".
#
# Патчинг:
#   ggml-*.so и libvisioncpp.so требуют rpath на соседние .so и системные
#   libvulkan.so.1 / libgomp.so.1. Без autoPatchelfHook ggml-vulkan.so
#   не загружается — Vulkan-бэкенд выключен, всё работает на CPU.
#
#   kritavisionml.so линкуется с внутренними библиотеками Krita 6
#   (libkritaui.so.21 и т.п.) и Qt6/KF6 — их нет в nixpkgs, подтягиваются
#   через dlopen из процесса Krita. Их игнорируем через
#   autoPatchelfIgnoreMissingDeps.
#
# Проверено readelf -d на v3.0.0:
#   NEEDED kritavisionml.so:  libvisioncpp.so.0, libkrita*.so.21 (8 шт),
#                             libKF6*.so.6 (3 шт), libQt6*.so.6 (3 шт),
#                             libggml*.so.0 (2 шт), libstdc++/libgcc_s/libc
#   NEEDED libvisioncpp.so.0: libggml*.so.0 (2 шт), libstdc++/libm/libgcc_s/libc
#   NEEDED ggml-vulkan.so:    libggml-base.so.0, libvulkan.so.1, libstdc++/libm/libgcc_s/libc
#   dlopen:                   нет (только libstdc++, она уже в NEEDED)

{ lib
, stdenv
, fetchzip
, autoPatchelfHook
, gcc
, vulkan-loader
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "krita-vision-tools";
  version = "3.0.0";

  src = fetchzip {
    # Тег v3.0.0-pre — единственное место, где лежит Linux-архив (см. шапку).
    url = "https://github.com/Acly/krita-vision-tools/releases/download/v3.0.0-pre/krita_vision_tools-linux-x64-${finalAttrs.version}.zip";
    hash = "sha256-y2+U2NXQnSmV3uFHNwsu47l2gR8j0TePiBRp7fywo2o=";
    stripRoot = false;
  };

  nativeBuildInputs = [ autoPatchelfHook ];

  buildInputs = [
    gcc.cc.lib        # libstdc++.so.6, libgomp.so.1
    vulkan-loader     # libvulkan.so.1
  ];

  # Внутренние библиотеки Krita 6, Qt6 и KF6, которые подгружаются dlopen-ом
  # из процесса Krita — их нет отдельными пакетами в nixpkgs.
  # Версии .21 (Krita 6) и .6 (Qt6/KF6) — в отличие от .19/.5 в Krita 5.
  autoPatchelfIgnoreMissingDeps = [
    "libkritaui.so.21"
    "libkritaimage.so.21"
    "libkritaflake.so.21"
    "libkritapigment.so.21"
    "libkritacommand.so.21"
    "libkritawidgetutils.so.21"
    "libkritaresources.so.21"
    "libkritaglobal.so.21"
    "libKF6CoreAddons.so.6"
    "libKF6I18n.so.6"
    "libKF6ConfigCore.so.6"
    "libQt6Widgets.so.6"
    "libQt6Gui.so.6"
    "libQt6Core.so.6"
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

    # Подкладываем BiRefNet-F16.gguf (420 МБ, лежит на /mnt/ai) внутрь
    # папки моделей плагина — чтобы он был виден в диалоге Background
    # Removal рядом с bundled BiRefNet-lite.
    #
    # ВАЖНО: target — абсолютный путь вне /nix/store. Если /mnt/ai не
    # смонтирован, симлинк будет висячим (как и любой /mnt/ai-референс).
    # Это осознанный компромисс ради простоты: не надо реконструировать
    # всю структуру vision_tools через tmpfiles.
    ln -sf /mnt/ai/ComfyUI_Krita-Vision-Tools/BiRefNet-F16.gguf \
      $out/share/krita/pykrita/vision_tools/models/birefnet/BiRefNet-F16.gguf

    runHook postInstall
  '';

  meta = with lib; {
    description = "Krita plugin for ML-based object selection and background removal";
    homepage = "https://github.com/Acly/krita-vision-tools";
    license = licenses.gpl3Only;
    platforms = [ "x86_64-linux" ];
  };
})
