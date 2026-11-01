# pkgs/pkg_krita-ai-diffusion.nix
#
# Плагин для Krita: генерация изображений через Stable Diffusion / Flux
# Работает как клиент к внешнему ComfyUI-серверу (server_mode = "external")
#
# ╔═══════════════════════════════════════════════════════════════════════╗
# ║  ⚠️  ВЕРСИЯ 1.54.0-pre — PRE-RELEASE, НЕ СТАБИЛЬНАЯ                   ║
# ╚═══════════════════════════════════════════════════════════════════════╝
#
# Используем release asset (ZIP), а НЕ git tree по тегу:
# в репозитории есть .gitattributes с "export-ignore" на websockets/ и debugpy/,
# поэтому автоматический архив от GitHub их не содержит. Без них плагин
# падает с "Could not find websockets module". Release ZIP собирается CI
# и содержит вендорные библиотеки
#
# websockets вендорен внутри плагина (ai_diffusion/websockets/) и
# импортируется относительным путём (from ..websockets.src import websockets)
# Внешний python3Packages.websockets НЕ нужен
#
# fetchzip даёт hash от РАСПАКОВАННОГО содержимого — не от zip-файла

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
