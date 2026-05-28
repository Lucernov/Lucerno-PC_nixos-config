# modules/nx_comfyui.nix
# Модуль для настройки системного сервиса ComfyUI через flake utensils/comfyui-nix
{ config, pkgs, myLib, lib, ... }:   # lib добавлен для lib.mkForce

{
  # Добавляем правила tmpfiles к существующим (не перезаписываем!)
  systemd.tmpfiles.rules = lib.mkAfter [
    # Создаём папку custom_nodes, если её нет
    "d /mnt/ai/ComfyUI/custom_nodes 0755 lucerno lucerno -"
    # Симлинки для кастомных нод из отдельной папки
    "L+ /mnt/ai/ComfyUI/custom_nodes/comfyui_controlnet_aux - - - - /mnt/ai/ComfyUI_krita-ai-diffusion/comfyui_controlnet_aux"
    "L+ /mnt/ai/ComfyUI/custom_nodes/comfyui-inpaint-nodes - - - - /mnt/ai/ComfyUI_krita-ai-diffusion/comfyui-inpaint-nodes"
    "L+ /mnt/ai/ComfyUI/custom_nodes/ComfyUI_IPAdapter_plus - - - - /mnt/ai/ComfyUI_krita-ai-diffusion/ComfyUI_IPAdapter_plus"
    "L+ /mnt/ai/ComfyUI/custom_nodes/comfyui-tooling-nodes - - - - /mnt/ai/ComfyUI_krita-ai-diffusion/comfyui-tooling-nodes"
  ];
}
