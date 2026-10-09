# pkgs/pkg_krita-ai-diffusion.nix
#
# Плагин для Krita: генерация изображений через Stable Diffusion / Flux.
# Работает как клиент к внешнему ComfyUI-серверу (server_mode = "external").
#
# Используем release asset (ZIP), а НЕ git tree по тегу:
# в репозитории есть .gitattributes с "export-ignore" на websockets/ и debugpy/,
# поэтому автоматический архив от GitHub их не содержит. Без них плагин
# падает с "Could not find websockets module". Release ZIP собирается CI
# и содержит вендорные библиотеки.
#
# fetchzip даёт hash от РАСПАКОВАННОГО содержимого — не от zip-файла.
#
# ВАЖНО: версия 1.53.0 — ПОСЛЕДНЯЯ, совместимая с Krita 5 (Qt 5 / PyQt5).
# Начиная с 1.54 плагин мигрировал на PyQt6 и требует Krita 6.
# Обновлять только вместе с переходом на Krita 6.
#
# ПРИМЕЧАНИЕ: плагин vision_tools (Vision Tools) НЕ входит в этот релиз —
# это отдельный проект, ставится отдельно.

{ lib
, stdenv
, fetchzip
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "krita-ai-diffusion";
  version = "1.53.0";

  src = fetchzip {
    url = "https://github.com/Acly/krita-ai-diffusion/releases/download/v${finalAttrs.version}/krita_ai_diffusion-${finalAttrs.version}.zip";
    hash = "sha256-rzJmqjRP7Ns2jhG5L4e/OpHGrL5EagDIweQGR5by3+0=";
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
    description = "Generative AI for Krita — клиент к внешнему ComfyUI-серверу";
    homepage = "https://github.com/Acly/krita-ai-diffusion";
    license = licenses.gpl3Only;
    platforms = [ "x86_64-linux" ];
  };
})
