# modules/links.nix
{ pkgs, lib, myLib, config ? null }:

let
  inherit (myLib) home;
  configDir = myLib.configDirName;
in
{
  # ========== Системные правила (требуют root) ==========
  systemRules = [
    # ---------- Директории ----------
    "d ${home}/${configDir} 0755 lucerno lucerno -"
    "d ${home}/.local/share 0755 lucerno lucerno -"
    "d ${home}/.config 0755 lucerno lucerno -"
    "d ${home}/${configDir}/secrets 0750 lucerno lucerno -"

    "d /mnt/ai 0755 lucerno lucerno -"
    "d /mnt/sys_archiv 0755 lucerno lucerno -"

    # линки rclone
    "d /mnt/www-GoogleDrive 0755 lucerno users -"
    "d /mnt/www-OneDrive 0755 lucerno users -"

    # линки ComfyUI
    "d /mnt/ai/ComfyUI/custom_nodes 0755 lucerno lucerno -"
    "d /mnt/ai/ComfyUI/models/diffusion_models 0755 lucerno lucerno -"
    "d /mnt/ai/ComfyUI/models/inpaint 0755 lucerno lucerno -"
    "d /mnt/ai/ComfyUI/models/loras 0755 lucerno lucerno -"
    "d /mnt/ai/ComfyUI/models/text_encoders 0755 lucerno lucerno -"
    "d /mnt/ai/ComfyUI/models/upscale_models 0755 lucerno lucerno -"
    "d /mnt/ai/ComfyUI/models/vae 0755 lucerno lucerno -"

    # sudo systemd-tmpfiles --create

    # ---------- Права на энергопотребление CPU чтобы в btop показывало потребление питания процессора  ----------
    "z /sys/class/powercap/intel-rapl:*/energy_uj 0640 root powercap -"

    # ---------- Симлинки конфигов (из ~/nixos-config/dotfiles/config) ----------
    "L+ ${home}/.config/nix - lucerno lucerno - ${home}/${configDir}/dotfiles/config/nix"
    "L+ ${home}/.config/btop - lucerno lucerno - ${home}/${configDir}/dotfiles/config/btop"
    "L+ ${home}/.config/qmmp - lucerno lucerno - ${home}/${configDir}/dotfiles/config/qmmp"
    "L+ ${home}/.config/SocialStream - lucerno lucerno - ${home}/${configDir}/dotfiles/config/SocialStream"
    "L+ ${home}/.config/obs-studio - lucerno lucerno - ${home}/${configDir}/dotfiles/config/obs-studio"
    "L+ ${home}/.config/REAPER - lucerno lucerno - ${home}/${configDir}/dotfiles/config/REAPER"
    "L+ ${home}/.config/yabridgectl - lucerno lucerno - ${home}/${configDir}/dotfiles/config/yabridgectl"
    "L+ ${home}/.config/MangoHud - lucerno lucerno - ${home}/${configDir}/dotfiles/config/MangoHud"
    "L+ ${home}/.config/kglobalshortcutsrc - lucerno lucerno - ${home}/${configDir}/dotfiles/config/KDE/config-kglobalshortcutsrc"
    "L+ ${home}/.local/share/applications/net.local.kitten - lucerno lucerno - ${home}/${configDir}/dotfiles/config/KDE/local-share-applications-net.local.kitten"
    "L+ ${home}/.p10k.zsh - lucerno lucerno - ${home}/${configDir}/dotfiles/config/zsh/.p10k.zsh"

    # ---------- Симлинки для Steam и игр ----------
    "L+ ${home}/.local/share/Steam/userdata - lucerno lucerno - ${home}/${configDir}/dotfiles/config/Steam/userdata"
    "L+ ${home}/.local/share/Steam/steamapps - lucerno lucerno - /mnt/games/SteamLibrary/steamapps"

    # ---------- Симлинки для приложений и данных ----------
    "L+ ${home}/.git-credentials - lucerno lucerno - /mnt/sys_archiv/secrets/git-credentials"
    "L+ ${home}/.config/rclone - lucerno lucerno - /mnt/sys_archiv/secrets/rclone"
    "L+ ${home}/.config/AmneziaVPN.ORG - lucerno lucerno - /mnt/sys_archiv/secrets/AmneziaVPN.ORG"
    "L+ ${home}/drum_sklad - lucerno lucerno - /mnt/sys_archiv/samples/drum_sklad"
    "L+ ${home}/.local/share/vital - lucerno lucerno - /mnt/sys_archiv/samples/vital"
    "L+ ${home}/.local/bin/socialstreamninja - lucerno lucerno - /mnt/sys_archiv/pkgs/AppImages/socialstreamninja_linux_v0.3.128_x86_64.AppImage"
    "L+ ${home}/.config/DecentSampler - lucerno lucerno - /mnt/sys_archiv/samples/DecentSampler"

    # ---------- Симлинки ComfyUI (в /mnt/ai) ----------
    # Удаляем старые папки перед созданием ссылок (R — удаление рекурсивное)
    "R /mnt/ai/ComfyUI/custom_nodes/comfyui_controlnet_aux - - - - -"
    "L+ /mnt/ai/ComfyUI/custom_nodes/comfyui_controlnet_aux - lucerno lucerno - /mnt/ai/ComfyUI_krita-ai-diffusion/comfyui_controlnet_aux"

    "R /mnt/ai/ComfyUI/custom_nodes/comfyui-inpaint-nodes - - - - -"
    "L+ /mnt/ai/ComfyUI/custom_nodes/comfyui-inpaint-nodes - lucerno lucerno - /mnt/ai/ComfyUI_krita-ai-diffusion/comfyui-inpaint-nodes"

    "R /mnt/ai/ComfyUI/custom_nodes/ComfyUI_IPAdapter_plus - - - - -"
    "L+ /mnt/ai/ComfyUI/custom_nodes/ComfyUI_IPAdapter_plus - lucerno lucerno - /mnt/ai/ComfyUI_krita-ai-diffusion/ComfyUI_IPAdapter_plus"

    "R /mnt/ai/ComfyUI/custom_nodes/comfyui-tooling-nodes - - - - -"
    "L+ /mnt/ai/ComfyUI/custom_nodes/comfyui-tooling-nodes - lucerno lucerno - /mnt/ai/ComfyUI_krita-ai-diffusion/comfyui-tooling-nodes"

    # Модели (файлы, не папки) — просто ссылки
    "L+ /mnt/ai/ComfyUI/models/diffusion_models/flux-2-klein-4b-fp8.safetensors - lucerno lucerno - /mnt/ai/ComfyUI_krita-ai-diffusion/models/diffusion_models/flux-2-klein-4b-fp8.safetensors"
    "L+ /mnt/ai/ComfyUI/models/diffusion_models/flux-2-klein-4b-Q6_K.gguf - lucerno lucerno - /mnt/ai/ComfyUI_krita-ai-diffusion/models/diffusion_models/flux-2-klein-4b-Q6_K.gguf"
    "L+ /mnt/ai/ComfyUI/models/inpaint/MAT_Places512_G_fp16.safetensors - lucerno lucerno - /mnt/ai/ComfyUI_krita-ai-diffusion/models/inpaint/MAT_Places512_G_fp16.safetensors"
    "L+ /mnt/ai/ComfyUI/models/loras/LyNiaZ53Tudg0J6sT8Xbx_pytorch_lora_weights_comfy_converted.safetensors - lucerno lucerno - /mnt/ai/ComfyUI_krita-ai-diffusion/models/loras/LyNiaZ53Tudg0J6sT8Xbx_pytorch_lora_weights_comfy_converted.safetensors"
    "L+ /mnt/ai/ComfyUI/models/text_encoders/Qwen3-4B-Q4_K_M.gguf - lucerno lucerno - /mnt/ai/ComfyUI_krita-ai-diffusion/models/text_encoders/Qwen3-4B-Q4_K_M.gguf"

    # Upscale модели
    "L+ /mnt/ai/ComfyUI/models/upscale_models/4x_NMKD-Superscale-SP_178000_G.pth - lucerno lucerno - /mnt/ai/ComfyUI_krita-ai-diffusion/models/upscale_models/4x_NMKD-Superscale-SP_178000_G.pth"
    "L+ /mnt/ai/ComfyUI/models/upscale_models/HAT_SRx4_ImageNet-pretrain.pth - lucerno lucerno - /mnt/ai/ComfyUI_krita-ai-diffusion/models/upscale_models/HAT_SRx4_ImageNet-pretrain.pth"
    "L+ /mnt/ai/ComfyUI/models/upscale_models/OmniSR_X2_DIV2K.safetensors - lucerno lucerno - /mnt/ai/ComfyUI_krita-ai-diffusion/models/upscale_models/OmniSR_X2_DIV2K.safetensors"
    "L+ /mnt/ai/ComfyUI/models/upscale_models/OmniSR_X3_DIV2K.safetensors - lucerno lucerno - /mnt/ai/ComfyUI_krita-ai-diffusion/models/upscale_models/OmniSR_X3_DIV2K.safetensors"
    "L+ /mnt/ai/ComfyUI/models/upscale_models/OmniSR_X4_DIV2K.safetensors - lucerno lucerno - /mnt/ai/ComfyUI_krita-ai-diffusion/models/upscale_models/OmniSR_X4_DIV2K.safetensors"
    "L+ /mnt/ai/ComfyUI/models/upscale_models/Real_HAT_GAN_sharper.pth - lucerno lucerno - /mnt/ai/ComfyUI_krita-ai-diffusion/models/upscale_models/Real_HAT_GAN_sharper.pth"
    "L+ /mnt/ai/ComfyUI/models/vae/flux2-vae.safetensors - lucerno lucerno - /mnt/ai/ComfyUI_krita-ai-diffusion/models/vae/flux2-vae.safetensors"

    # Ссылка ~/.config/comfy-ui на /mnt/ai/ComfyUI (тоже с удалением старой папки)
    "R ${home}/.config/comfy-ui - - - - -"
    "L+ ${home}/.config/comfy-ui - lucerno lucerno - /mnt/ai/ComfyUI"
  ];

  # ========== Скрипт для home.activation (пустой, т.к. всё перенесено в systemRules) ==========
  activationScript = lib.mkIf (config != null) "";
}
