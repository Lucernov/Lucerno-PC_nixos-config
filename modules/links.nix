{ pkgs, pkgs-unstable, lib, myLib, config, ... }:

let
  inherit (myLib) home;
  configDir = myLib.configDirName;
in
{
  systemd.tmpfiles.rules = [
    # .zshrc
    "L+ ${home}/.zshrc - lucerno lucerno - ${pkgs.writeText ".zshrc" "source /etc/zshrc"}"

    # ---------- Директории ----------
    "d ${home}/${configDir} 0755 lucerno lucerno -"
    "d ${home}/.local/share 0755 lucerno lucerno -"
    "d ${home}/.config 0755 lucerno lucerno -"
    "d ${home}/${configDir}/secrets 0750 lucerno lucerno -"
    "d ${home}/.local/share/applications 0755 lucerno lucerno -"
    "d ${home}/.local/bin 0755 lucerno lucerno -"
    "d ${home}/.local/share/Steam/config 0755 lucerno lucerno -"
    "d ${home}/.config/autostart 0755 lucerno lucerno -"                                      # для автозапуска

    "d /mnt/ai 0755 lucerno lucerno -"
    "d /mnt/sys_archiv 0755 lucerno lucerno -"
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

    # ---------- Права на энергопотребление CPU ----------
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
    "R /mnt/ai/ComfyUI/custom_nodes/comfyui_controlnet_aux - - - - -"
    "L+ /mnt/ai/ComfyUI/custom_nodes/comfyui_controlnet_aux - lucerno lucerno - /mnt/ai/ComfyUI_krita-ai-diffusion/comfyui_controlnet_aux"

    "R /mnt/ai/ComfyUI/custom_nodes/comfyui-inpaint-nodes - - - - -"
    "L+ /mnt/ai/ComfyUI/custom_nodes/comfyui-inpaint-nodes - lucerno lucerno - /mnt/ai/ComfyUI_krita-ai-diffusion/comfyui-inpaint-nodes"

    "R /mnt/ai/ComfyUI/custom_nodes/ComfyUI_IPAdapter_plus - - - - -"
    "L+ /mnt/ai/ComfyUI/custom_nodes/ComfyUI_IPAdapter_plus - lucerno lucerno - /mnt/ai/ComfyUI_krita-ai-diffusion/ComfyUI_IPAdapter_plus"

    "R /mnt/ai/ComfyUI/custom_nodes/comfyui-tooling-nodes - - - - -"
    "L+ /mnt/ai/ComfyUI/custom_nodes/comfyui-tooling-nodes - lucerno lucerno - /mnt/ai/ComfyUI_krita-ai-diffusion/comfyui-tooling-nodes"

    # Модели
    "L+ /mnt/ai/ComfyUI/models/diffusion_models/flux-2-klein-4b-fp8.safetensors - lucerno lucerno - /mnt/ai/ComfyUI_krita-ai-diffusion/models/diffusion_models/flux-2-klein-4b-fp8.safetensors"
    "L+ /mnt/ai/ComfyUI/models/diffusion_models/flux-2-klein-4b-Q6_K.gguf - lucerno lucerno - /mnt/ai/ComfyUI_krita-ai-diffusion/models/diffusion_models/flux-2-klein-4b-Q6_K.gguf"
    "L+ /mnt/ai/ComfyUI/models/inpaint/MAT_Places512_G_fp16.safetensors - lucerno lucerno - /mnt/ai/ComfyUI_krita-ai-diffusion/models/inpaint/MAT_Places512_G_fp16.safetensors"
    "L+ /mnt/ai/ComfyUI/models/loras/LyNiaZ53Tudg0J6sT8Xbx_pytorch_lora_weights_comfy_converted.safetensors - lucerno lucerno - /mnt/ai/ComfyUI_krita-ai-diffusion/models/loras/LyNiaZ53Tudg0J6sT8Xbx_pytorch_lora_weights_comfy_converted.safetensors"
    "L+ /mnt/ai/ComfyUI/models/text_encoders/Qwen3-4B-Q4_K_M.gguf - lucerno lucerno - /mnt/ai/ComfyUI_krita-ai-diffusion/models/text_encoders/Qwen3-4B-Q4_K_M.gguf"
    "L+ /mnt/ai/ComfyUI/models/upscale_models/4x_NMKD-Superscale-SP_178000_G.pth - lucerno lucerno - /mnt/ai/ComfyUI_krita-ai-diffusion/models/upscale_models/4x_NMKD-Superscale-SP_178000_G.pth"
    "L+ /mnt/ai/ComfyUI/models/upscale_models/HAT_SRx4_ImageNet-pretrain.pth - lucerno lucerno - /mnt/ai/ComfyUI_krita-ai-diffusion/models/upscale_models/HAT_SRx4_ImageNet-pretrain.pth"
    "L+ /mnt/ai/ComfyUI/models/upscale_models/OmniSR_X2_DIV2K.safetensors - lucerno lucerno - /mnt/ai/ComfyUI_krita-ai-diffusion/models/upscale_models/OmniSR_X2_DIV2K.safetensors"
    "L+ /mnt/ai/ComfyUI/models/upscale_models/OmniSR_X3_DIV2K.safetensors - lucerno lucerno - /mnt/ai/ComfyUI_krita-ai-diffusion/models/upscale_models/OmniSR_X3_DIV2K.safetensors"
    "L+ /mnt/ai/ComfyUI/models/upscale_models/OmniSR_X4_DIV2K.safetensors - lucerno lucerno - /mnt/ai/ComfyUI_krita-ai-diffusion/models/upscale_models/OmniSR_X4_DIV2K.safetensors"
    "L+ /mnt/ai/ComfyUI/models/upscale_models/Real_HAT_GAN_sharper.pth - lucerno lucerno - /mnt/ai/ComfyUI_krita-ai-diffusion/models/upscale_models/Real_HAT_GAN_sharper.pth"
    "L+ /mnt/ai/ComfyUI/models/vae/flux2-vae.safetensors - lucerno lucerno - /mnt/ai/ComfyUI_krita-ai-diffusion/models/vae/flux2-vae.safetensors"

    "R ${home}/.config/comfy-ui - - - - -"
    "L+ ${home}/.config/comfy-ui - lucerno lucerno - /mnt/ai/ComfyUI"

    # ---------- Автозапуск ----------
    # AmneziaVPN
    "L+ ${home}/.config/autostart/amneziavpn.desktop - lucerno lucerno - ${pkgs.writeText "amneziavpn.desktop" ''
      [Desktop Entry]
      Type=Application
      Name=AmneziaVPN
      Exec=amnezia-vpn
      Icon=amnezia-vpn
      X-KDE-autostart-after=panel
      StartupNotify=false
      Terminal=false
    ''}"

    # ---------- Переопределение путей пдомашних папок (генерируемые через pkgs.writeText) ----------
    "L+ ${home}/.config/user-dirs.dirs - lucerno lucerno - ${pkgs.writeText "user-dirs.dirs" ''
      XDG_DESKTOP_DIR="$HOME/Desktop"
      XDG_DOWNLOAD_DIR="$HOME/Загрузки"
      XDG_TEMPLATES_DIR="$HOME/Templates"
      XDG_PUBLICSHARE_DIR="$HOME/Public"
      XDG_DOCUMENTS_DIR="/mnt/docs"
      XDG_MUSIC_DIR="/mnt/music"
      XDG_PICTURES_DIR="/mnt/images"
      XDG_VIDEOS_DIR="/mnt/video"
    ''}"

    # Конфигурационный файл Git (~/.gitconfig)
    "L+ ${home}/.gitconfig - lucerno lucerno - ${pkgs.writeText "gitconfig" ''
      [user]
        name = Lucernov
        email = jin.riv@gmail.com
      [core]
        excludesfile = ~/.gitignore
        hooksPath = ~/.git/hooks
      [credential]
        helper = store
    ''}"

    # Глобальный файл игнорирования Git (~/.gitignore)
    "L+ ${home}/.gitignore - lucerno lucerno - ${pkgs.writeText "gitignore" ''
      *.swp
      *~
      .Trash-*
      result
    ''}"

    # --- Указывает количество потоков для компиляции шейдеров в Steam ---
    "L+ ${home}/.local/share/Steam/config/steam_dev.cfg - lucerno lucerno - ${pkgs.writeText "steam_dev.cfg" ''
      unShaderBackgroundProcessingThreads 16
    ''}"

    # ---------- .desktop файлы ----------
    # --- Ярлык REAPER в меню KDE с кастомным запусском ---
    "L+ ${home}/.local/share/applications/reaper-x11.desktop - lucerno lucerno - ${pkgs.writeText "reaper-x11.desktop" ''
      [Desktop Entry]
      Version=1.0
      Type=Application
      Name=REAPER
      Comment=ПРОСТО БОЛЬ !!!
      Exec=/run/current-system/sw/bin/reaper %F
      Icon=cockos-reaper
      Categories=Audio;AudioVideo;
      Terminal=false
      StartupWMClass=REAPER
    ''}"

    # --- Ярлык Minion в меню KDE ---
    "L+ ${home}/.local/share/applications/minion.desktop - lucerno lucerno - ${pkgs.writeText "minion.desktop" ''
      [Desktop Entry]
      Version=1.0
      Type=Application
      Name=Minion
      Comment=Управление аддонами для MMORPG
      Exec=minion
      Icon=${home}/${configDir}/dotfiles/sys-icons/icon-minion.png
      Categories=Game;
      Terminal=false
      StartupWMClass=Minion
    ''}"

    # --- Ярлык QMMP в меню KDE с кастомным запусском ---
    "L+ ${home}/.local/share/applications/org.qmmp.qmmp.desktop - lucerno lucerno - ${pkgs.writeText "org.qmmp.qmmp.desktop" ''
      [Desktop Entry]
      Name=Qmmp
      Exec=/run/current-system/sw/bin/qmmp %F
      Icon=qmmp
      Terminal=false
      Type=Application
      Categories=Audio;AudioVideo;
    ''}"

    # --- Ярлык Ampero ---
    "L+ ${home}/.local/share/applications/ampero2.desktop - lucerno lucerno - ${pkgs.writeText "ampero2.desktop" ''
      [Desktop Entry]
      Type=Application
      Name=Ampero II
      Comment=Hotone Ampero II Editor
      Exec=env WINEPREFIX="/mnt/music/wine/wine-guitar" wine "/mnt/music/wine/wine-guitar/drive_c/Program Files/Hotone/Ampero II/Ampero II.exe"
      Icon=${home}/${configDir}/dotfiles/sys-icons/icon-hotone.png
      Categories=Audio;AudioVideo;
      StartupNotify=true
      Terminal=false
    ''}"

    # --- Ярлык SocialStreamNinja приложение AppImage в меню KDE ---
    "L+ ${home}/.local/share/applications/socialstreamninja.desktop - lucerno lucerno - ${pkgs.writeText "socialstreamninja.desktop" ''
      [Desktop Entry]
      Version=1.0
      Type=Application
      Name=SocialStreamNinja
      Comment=Управление социальными сетями
      Exec=socialstreamninja
      Icon=${home}/${configDir}/dotfiles/sys-icons/icon-SocialStreamNinja.png
      Categories=Network;
      Terminal=false
      StartupNotify=true
    ''}"

    # --- Ярлык Google Chrome с принудительным X11 ---
    "L+ ${home}/.local/share/applications/google-chrome.desktop - lucerno lucerno - ${pkgs.writeText "google-chrome.desktop" ''
      [Desktop Entry]
      Version=1.0
      Type=Application
      Name=Google Chrome
      Exec=google-chrome-stable --ozone-platform=x11 %U
      Icon=google-chrome
      Categories=Network;WebBrowser;
      Terminal=false
      StartupWMClass=Google-chrome-stable
    ''}"

    # kitten
    "L+ ${home}/.local/share/applications/net.local.kitten.desktop - lucerno lucerno - ${pkgs.writeText "net.local.kitten.desktop" ''
      [Desktop Entry]
      Type=Application
      Name=Kitten
      Exec=/run/current-system/sw/bin/kitten %F
      Icon=org.nixos.kitten
      Categories=Network;
      Terminal=false
      StartupNotify=true
    ''}"

    # Удаляем старый сокет Kitty, чтобы новый создавался с правильным именем
    "R /tmp/kitty-sock - - - - -"
    # Скрипт запуска КИТТИ через Win+Z (без kitten)
    "L+ ${home}/.local/bin/toggle-kitty 0755 lucerno lucerno - ${pkgs.writeShellScript "toggle-kitty" ''
      if kitty @ get-window-id --match title:"quick-access" 2>/dev/null; then
          kitty @ close-window --match title:"quick-access"
      else
          kitten quick-access-terminal
      fi
    ''}"

    # ---------- ПРАВИЛА ДЛЯ АУДИО ----------
    "d ${home}/.vst3 0755 lucerno lucerno -"
    "d ${home}/.config/REAPER/UserPlugins 0755 lucerno lucerno -"                             # для .so файлов REAPER
    # wine64
    "L+ ${home}/.local/bin/wine64 - lucerno lucerno - ${pkgs-unstable.wineWow64Packages.staging}/bin/wine"
    # .so файлы REAPER
    "L+ ${home}/.config/REAPER/UserPlugins/reaper_sws-x86_64.so - lucerno lucerno - ${pkgs-unstable.reaper-sws-extension}/UserPlugins/reaper_sws-x86_64.so"
    "L+ ${home}/.config/REAPER/UserPlugins/reaper_reapack-x86_64.so - lucerno lucerno - ${pkgs-unstable.reaper-reapack-extension}/UserPlugins/reaper_reapack-x86_64.so"
    # ---------- Каталоги для drop‑in файлов systemd --user ----------
    "d ${home}/.config/systemd 0755 lucerno lucerno -"
    "d ${home}/.config/systemd/user 0755 lucerno lucerno -"
    "d ${home}/.config/systemd/user/pipewire.service.d 0755 lucerno lucerno -"
    "d ${home}/.config/systemd/user/pipewire-pulse.service.d 0755 lucerno lucerno -"
    "d ${home}/.config/systemd/user/wireplumber.service.d 0755 lucerno lucerno -"
    # ---------- Настройка приоритетов реального времени для PipeWire и WirePlumber ----------
    "f ${home}/.config/systemd/user/pipewire.service.d/99-realtime.conf 0644 lucerno lucerno - ${pkgs.writeText "99-realtime.conf" ''
    [Service]
    CPUSchedulingPolicy=fifo
    CPUSchedulingPriority=85
    Nice=-11
    LimitRTPRIO=89
    ''}"

    "f ${home}/.config/systemd/user/pipewire-pulse.service.d/99-realtime.conf 0644 lucerno lucerno - ${pkgs.writeText "99-realtime.conf" ''
    [Service]
    CPUSchedulingPolicy=fifo
    CPUSchedulingPriority=85
    Nice=-11
    LimitRTPRIO=89
    ''}"

    "f ${home}/.config/systemd/user/wireplumber.service.d/99-realtime.conf 0644 lucerno lucerno - ${pkgs.writeText "99-realtime.conf" ''
    [Service]
    CPUSchedulingPolicy=fifo
    CPUSchedulingPriority=85
    Nice=-11
    LimitRTPRIO=89
    ''}"
  ];
}
