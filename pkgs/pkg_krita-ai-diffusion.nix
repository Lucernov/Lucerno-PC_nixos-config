# pkgs/pkg_krita-ai-diffusion.nix
#
# Плагин для Krita: генерация изображений через Stable Diffusion / Flux.
# Работает как клиент к внешнему ComfyUI-серверу (server_mode = "external").
#
# ╔═══════════════════════════════════════════════════════════════════════╗
# ║  ⚠️  ВЕРСИЯ 1.54.0-pre — PRE-RELEASE, НЕ СТАБИЛЬНАЯ                   ║
# ║                                                                       ║
# ║  Апстрим явно помечает её как pre-release. Автор пишет:               ║
# ║  "Migrated to Krita 6 / Qt6. No longer works with Krita 5.x!"         ║
# ║  "has not been extensively tested"                                    ║
# ║  Рекомендуемая автором Krita: 6.0.4 (у нас 6.0.2.1).                  ║
# ║                                                                       ║
# ║  Если плагин падает или ведёт себя странно — это ожидаемо.            ║
# ║  Стабильного релиза для Krita 6 пока нет. Откат — на тег              ║
# ║  pre-krita-stable-2026-11-01 (там 1.53.0 для Krita 5).                ║
# ╚═══════════════════════════════════════════════════════════════════════╝
#
# Используем release asset (ZIP), а НЕ git tree по тегу:
# в репозитории есть .gitattributes с "export-ignore" на websockets/ и debugpy/,
# поэтому автоматический архив от GitHub их не содержит. Без них плагин
# падает с "Could not find websockets module". Release ZIP собирается CI
# и содержит вендорные библиотеки.
#
# websockets вендорен внутри плагина (ai_diffusion/websockets/) и
# импортируется относительным путём (from ..websockets.src import websockets).
# Внешний python3Packages.websockets НЕ нужен.
#
# fetchzip даёт hash от РАСПАКОВАННОГО содержимого — не от zip-файла.
#
# История версий:
#   1.53.0         — последняя стабильная для Krita 5.2 (Qt5/PyQt5). Снята.
#   1.54.0-pre     — единственная доступная для Krita 6 (Qt6/PyQt6).
#   Стабильной 1.54 пока нет (по состоянию на дату миграции).
#
# ПРИМЕЧАНИЕ: плагин vision_tools (Vision Tools) НЕ входит в этот релиз —
# это отдельный проект, ставится отдельно.

{ lib
, stdenv
, fetchzip
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "krita-ai-diffusion";
  version = "1.54.0-pre";

  src = fetchzip {
    url = "https://github.com/Acly/krita-ai-diffusion/releases/download/v${finalAttrs.version}/krita_ai_diffusion-${finalAttrs.version}.zip";
    hash = "sha256-0okMfg1XOyopbWmTzGESN0jVCCNP0hR5B3bomYsAj3Q=";
    stripRoot = false;
  };

  # fetchzip распаковывает автоматически; содержимое в корне:
  #   ai_diffusion/  ai_diffusion.desktop
  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/krita/pykrita
    cp -r ai_diffusion       $out/share/krita/pykrita/
    cp ai_diffusion.desktop  $out/share/krita/pykrita/

    runHook postInstall
  '';

  meta = with lib; {
    description = "Generative AI for Krita — клиент к внешнему ComfyUI-серверу (pre-release для Krita 6)";
    homepage = "https://github.com/Acly/krita-ai-diffusion";
    license = licenses.gpl3Only;
    platforms = [ "x86_64-linux" ];
  };
})
