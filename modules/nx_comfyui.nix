# modules/nx_comfyui.nix
# Модуль для настройки системного сервиса ComfyUI через flake utensils/comfyui-nix
{ config, pkgs, myLib, lib, ... }:   # lib добавлен для lib.mkForce

{
  # Добавляем правила tmpfiles к существующим (не перезаписываем!)
  systemd.tmpfiles.rules = lib.mkAfter [
    # Создаём папку custom_nodes, если её нет
    "d /mnt/ai/ComfyUI/custom_nodes 0755 lucerno lucerno -"
    "d /mnt/ai/ComfyUI/models/diffusion_models 0755 lucerno lucerno -"
    "d /mnt/ai/ComfyUI/models/inpaint 0755 lucerno lucerno -"
    "d /mnt/ai/ComfyUI/models/loras 0755 lucerno lucerno -"
    "d /mnt/ai/ComfyUI/models/text_encoders 0755 lucerno lucerno -"
    "d /mnt/ai/ComfyUI/models/upscale_models 0755 lucerno lucerno -"
    "d /mnt/ai/ComfyUI/models/vae 0755 lucerno lucerno -"
    # Krita
    "L+ /mnt/ai/ComfyUI/custom_nodes/comfyui_controlnet_aux - - - - /mnt/ai/ComfyUI_krita-ai-diffusion/comfyui_controlnet_aux"
    "L+ /mnt/ai/ComfyUI/custom_nodes/comfyui-inpaint-nodes - - - - /mnt/ai/ComfyUI_krita-ai-diffusion/comfyui-inpaint-nodes"
    "L+ /mnt/ai/ComfyUI/custom_nodes/ComfyUI_IPAdapter_plus - - - - /mnt/ai/ComfyUI_krita-ai-diffusion/ComfyUI_IPAdapter_plus"
    "L+ /mnt/ai/ComfyUI/custom_nodes/comfyui-tooling-nodes - - - - /mnt/ai/ComfyUI_krita-ai-diffusion/comfyui-tooling-nodes"
    "L+ /mnt/ai/ComfyUI/models/diffusion_models/flux-2-klein-4b-fp8.safetensors - - - - /mnt/ai/ComfyUI_krita-ai-diffusion/models/diffusion_models/flux-2-klein-4b-fp8.safetensors"
    "L+ /mnt/ai/ComfyUI/models/diffusion_models/flux-2-klein-4b-Q6_K.gguf - - - - /mnt/ai/ComfyUI_krita-ai-diffusion/models/diffusion_models/flux-2-klein-4b-Q6_K.gguf"
    "L+ /mnt/ai/ComfyUI/models/inpaint/MAT_Places512_G_fp16.safetensors - - - - /mnt/ai/ComfyUI_krita-ai-diffusion/models/inpaint/MAT_Places512_G_fp16.safetensors"
    "L+ /mnt/ai/ComfyUI/models/loras/LyNiaZ53Tudg0J6sT8Xbx_pytorch_lora_weights_comfy_converted.safetensors - - - - /mnt/ai/ComfyUI_krita-ai-diffusion/models/loras/LyNiaZ53Tudg0J6sT8Xbx_pytorch_lora_weights_comfy_converted.safetensors"
    "L+ /mnt/ai/ComfyUI/models/text_encoders/Qwen3-4B-Q4_K_M.gguf - - - - /mnt/ai/ComfyUI_krita-ai-diffusion/models/text_encoders/Qwen3-4B-Q4_K_M.gguf"
    "L+ /mnt/ai/ComfyUI/models/upscale_models/4x_NMKD-Superscale-SP_178000_G.pth - - - - /mnt/ai/ComfyUI_krita-ai-diffusion/models/upscale_models/4x_NMKD-Superscale-SP_178000_G.pth"
    "L+ /mnt/ai/ComfyUI/models/upscale_models/HAT_SRx4_ImageNet-pretrain.pth - - - - /mnt/ai/ComfyUI_krita-ai-diffusion/models/upscale_models/HAT_SRx4_ImageNet-pretrain.pth"
    "L+ /mnt/ai/ComfyUI/models/upscale_models/OmniSR_X2_DIV2K.safetensors - - - - /mnt/ai/ComfyUI_krita-ai-diffusion/models/upscale_models/OmniSR_X2_DIV2K.safetensors"
    "L+ /mnt/ai/ComfyUI/models/upscale_models/OmniSR_X3_DIV2K.safetensors - - - - /mnt/ai/ComfyUI_krita-ai-diffusion/models/upscale_models/OmniSR_X3_DIV2K.safetensors"
    "L+ /mnt/ai/ComfyUI/models/upscale_models/OmniSR_X4_DIV2K.safetensors - - - - /mnt/ai/ComfyUI_krita-ai-diffusion/models/upscale_models/OmniSR_X4_DIV2K.safetensors"
    "L+ /mnt/ai/ComfyUI/models/upscale_models/Real_HAT_GAN_sharper.pth - - - - /mnt/ai/ComfyUI_krita-ai-diffusion/models/upscale_models/Real_HAT_GAN_sharper.pth"
    "L+ /mnt/ai/ComfyUI/models/vae/flux2-vae.safetensors - - - - /mnt/ai/ComfyUI_krita-ai-diffusion/models/vae/flux2-vae.safetensors"
  ];
}
