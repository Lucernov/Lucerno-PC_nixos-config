# modules/nx_krita.nix
#
# Декларативная установка плагинов для Krita:
#   - krita-ai-diffusion (v1.53.0) — генерация изображений через ComfyUI
#   - krita-vision-tools (v2.1.0)  — выделение объектов и удаление фона
#
# Оба прибиты к последним версиям, совместимым с Krita 5.2 / Qt5.
# Обновлять только вместе с переходом на Krita 6.
#
# Пользовательские данные (ai_diffusion/, logs, presets, styles) остаются
# в $HOME и не трогаются. Код обоих плагинов идёт из /nix/store.
#
# ПРИМЕЧАНИЕ про vision_tools: релизный архив содержит только
# BiRefNet-lite-F16.gguf (84 МБ). Пользовательская BiRefNet-F16.gguf (420 МБ,
# на /mnt/ai/BiRefNet/) в деривацию не входит — если понадобится, плагин
# позволяет указать путь к ней через кнопку "Folder" в GUI.

{ pkgs, myLib, ... }:

let
  pluginAI = pkgs.my-packages.krita-ai-diffusion;
  pluginVT = pkgs.my-packages.krita-vision-tools;
in
{
  systemd.tmpfiles.rules = [
    # ---------- krita-ai-diffusion ----------
    "L+ ${myLib.home}/.local/share/krita/pykrita/ai_diffusion - ${myLib.userName} ${myLib.userName} - ${pluginAI}/share/krita/pykrita/ai_diffusion"
    "L+ ${myLib.home}/.local/share/krita/pykrita/ai_diffusion.desktop - ${myLib.userName} ${myLib.userName} - ${pluginAI}/share/krita/pykrita/ai_diffusion.desktop"

    # ---------- krita-vision-tools ----------
    "L+ ${myLib.home}/.local/share/krita/pykrita/vision_tools - ${myLib.userName} ${myLib.userName} - ${pluginVT}/share/krita/pykrita/vision_tools"
    "L+ ${myLib.home}/.local/share/krita/pykrita/vision_tools.desktop - ${myLib.userName} ${myLib.userName} - ${pluginVT}/share/krita/pykrita/vision_tools.desktop"
  ];
}
