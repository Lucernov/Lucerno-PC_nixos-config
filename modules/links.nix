# modules/links.nix
{ pkgs, lib, myLib, config ? null }:

let
  inherit (myLib) home;
  configDir = myLib.configDirName;
in
{
  # ========== Системные правила (требуют root) ==========
  systemRules = [
    "d ${home}/${myLib.configDirName} 0755 lucerno lucerno -"
    "d /mnt/ai 0755 lucerno lucerno -"
    "d /mnt/sys_archiv 0755 lucerno lucerno -"
    "z /sys/class/powercap/intel-rapl:*/energy_uj 0640 root powercap -"           # Переопределение прав, чтобы в btop показывало потребление питания процессора

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
  ];

  # ========== Скрипт для home.activation ==========
  # Вычисляется ТОЛЬКО если передан config (т.е. при импорте из home-manager)
  activationScript = lib.mkIf (config != null) ''
    # Создание директорий внутри ~/
    mkdir -p ${home}/.local/share && chmod 755 ${home}/.local/share
    mkdir -p ${home}/.config && chmod 755 ${home}/.config
    mkdir -p ${home}/${configDir}/secrets && chmod 750 ${home}/${configDir}/secrets

    # Прямые симлинки (БЕЗ копирования в Nix store)
    ln -sfn ${home}/${configDir}/dotfiles/config/nix ${home}/.config/nix
    ln -sfn /mnt/sys_archiv/secrets/git-credentials ${home}/.git-credentials
    ln -sfn /mnt/sys_archiv/secrets/rclone ${home}/.config/rclone
    ln -sfn /mnt/sys_archiv/secrets/AmneziaVPN.ORG ${home}/.config/AmneziaVPN.ORG
    ln -sfn /mnt/sys_archiv/samples/drum_sklad ${home}/drum_sklad
    ln -sfn ${home}/${configDir}/dotfiles/config/Steam/userdata ${home}/.local/share/Steam/userdata
    ln -sfn /mnt/sys_archiv/samples/vital ${home}/.local/share/vital
    ln -sfn ${home}/${configDir}/dotfiles/config/btop ${home}/.config/btop
    ln -sfn ${home}/${configDir}/dotfiles/config/qmmp ${home}/.config/qmmp
    ln -sfn /mnt/sys_archiv/pkgs/AppImages/socialstreamninja_linux_v0.3.128_x86_64.AppImage ${home}/.local/bin/socialstreamninja
    ln -sfn ${home}/${configDir}/dotfiles/config/SocialStream ${home}/.config/SocialStream
    ln -sfn ${home}/${configDir}/dotfiles/config/obs-studio ${home}/.config/obs-studio
    ln -sfn /mnt/sys_archiv/samples/DecentSampler ${home}/.config/DecentSampler
    ln -sfn ${home}/${configDir}/dotfiles/config/REAPER ${home}/.config/REAPER
    ln -sfn ${home}/${configDir}/dotfiles/config/yabridgectl ${home}/.config/yabridgectl
    ln -sfn ${home}/${configDir}/dotfiles/config/MangoHud ${home}/.config/MangoHud
    ln -sfn /mnt/games/SteamLibrary/steamapps ${home}/.local/share/Steam/steamapps
    ln -sfn ${home}/${configDir}/dotfiles/config/KDE/config-kglobalshortcutsrc ${home}/.config/kglobalshortcutsrc
    ln -sfn ${home}/${configDir}/dotfiles/config/KDE/local-share-applications-net.local.kitten ${home}/.local/share/applications/net.local.kitten

    # Симлинк для Powerlevel10k
    ln -sfn ${home}/${configDir}/dotfiles/config/zsh/.p10k.zsh ${home}/.p10k.zsh

    # ----- СИСТЕМНЫЕ СИМЛИНКИ ДЛЯ COMFYUI (в /mnt/ai) -----
    rm -rf ${home}/.config/comfy-ui
    ln -sfn /mnt/ai/ComfyUI ${home}/.config/comfy-ui

    rm -rf /mnt/ai/ComfyUI/custom_nodes/comfyui_controlnet_aux
    ln -sfn /mnt/ai/ComfyUI_krita-ai-diffusion/comfyui_controlnet_aux /mnt/ai/ComfyUI/custom_nodes/comfyui_controlnet_aux

    rm -rf /mnt/ai/ComfyUI/custom_nodes/comfyui-inpaint-nodes
    ln -sfn /mnt/ai/ComfyUI_krita-ai-diffusion/comfyui-inpaint-nodes /mnt/ai/ComfyUI/custom_nodes/comfyui-inpaint-nodes

    rm -rf /mnt/ai/ComfyUI/custom_nodes/ComfyUI_IPAdapter_plus
    ln -sfn /mnt/ai/ComfyUI_krita-ai-diffusion/ComfyUI_IPAdapter_plus /mnt/ai/ComfyUI/custom_nodes/ComfyUI_IPAdapter_plus

    rm -rf /mnt/ai/ComfyUI/custom_nodes/comfyui-tooling-nodes
    ln -sfn /mnt/ai/ComfyUI_krita-ai-diffusion/comfyui-tooling-nodes /mnt/ai/ComfyUI/custom_nodes/comfyui-tooling-nodes

    # Модели
    ln -sfn /mnt/ai/ComfyUI_krita-ai-diffusion/models/diffusion_models/flux-2-klein-4b-fp8.safetensors /mnt/ai/ComfyUI/models/diffusion_models/flux-2-klein-4b-fp8.safetensors
    ln -sfn /mnt/ai/ComfyUI_krita-ai-diffusion/models/diffusion_models/flux-2-klein-4b-Q6_K.gguf /mnt/ai/ComfyUI/models/diffusion_models/flux-2-klein-4b-Q6_K.gguf
    ln -sfn /mnt/ai/ComfyUI_krita-ai-diffusion/models/inpaint/MAT_Places512_G_fp16.safetensors /mnt/ai/ComfyUI/models/inpaint/MAT_Places512_G_fp16.safetensors
    ln -sfn /mnt/ai/ComfyUI_krita-ai-diffusion/models/loras/LyNiaZ53Tudg0J6sT8Xbx_pytorch_lora_weights_comfy_converted.safetensors /mnt/ai/ComfyUI/models/loras/LyNiaZ53Tudg0J6sT8Xbx_pytorch_lora_weights_comfy_converted.safetensors
    ln -sfn /mnt/ai/ComfyUI_krita-ai-diffusion/models/text_encoders/Qwen3-4B-Q4_K_M.gguf /mnt/ai/ComfyUI/models/text_encoders/Qwen3-4B-Q4_K_M.gguf

    # Upscale модели
    ln -sfn /mnt/ai/ComfyUI_krita-ai-diffusion/models/upscale_models/4x_NMKD-Superscale-SP_178000_G.pth /mnt/ai/ComfyUI/models/upscale_models/4x_NMKD-Superscale-SP_178000_G.pth
    ln -sfn /mnt/ai/ComfyUI_krita-ai-diffusion/models/upscale_models/HAT_SRx4_ImageNet-pretrain.pth /mnt/ai/ComfyUI/models/upscale_models/HAT_SRx4_ImageNet-pretrain.pth
    ln -sfn /mnt/ai/ComfyUI_krita-ai-diffusion/models/upscale_models/OmniSR_X2_DIV2K.safetensors /mnt/ai/ComfyUI/models/upscale_models/OmniSR_X2_DIV2K.safetensors
    ln -sfn /mnt/ai/ComfyUI_krita-ai-diffusion/models/upscale_models/OmniSR_X3_DIV2K.safetensors /mnt/ai/ComfyUI/models/upscale_models/OmniSR_X3_DIV2K.safetensors
    ln -sfn /mnt/ai/ComfyUI_krita-ai-diffusion/models/upscale_models/OmniSR_X4_DIV2K.safetensors /mnt/ai/ComfyUI/models/upscale_models/OmniSR_X4_DIV2K.safetensors
    ln -sfn /mnt/ai/ComfyUI_krita-ai-diffusion/models/upscale_models/Real_HAT_GAN_sharper.pth /mnt/ai/ComfyUI/models/upscale_models/Real_HAT_GAN_sharper.pth
    ln -sfn /mnt/ai/ComfyUI_krita-ai-diffusion/models/vae/flux2-vae.safetensors /mnt/ai/ComfyUI/models/vae/flux2-vae.safetensors
  '';
}
