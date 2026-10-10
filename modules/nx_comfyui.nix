# systemctl --user daemon-reload - перезагрузка сервисов
# systemctl --user restart comfyui - перезагрузка comfyui
# systemctl --user status comfyui - вывод статуса comfyui
{ pkgs, myLib, ... }:

let
  inherit (myLib) home;

  # Локализация ComfyUI от Nestorchik.
  # Обновление: посмотреть новый коммит на
  #   https://github.com/Nestorchik/NStor-ComfyUI-Translation/commits/main
  # Получить rev+hash:
  #   nix run nixpkgs#nix-prefetch-github -- Nestorchik NStor-ComfyUI-Translation --rev main
  # Заменить rev и hash ниже.
  nstor-translation = pkgs.fetchFromGitHub {
    owner = "Nestorchik";
    repo = "NStor-ComfyUI-Translation";
    rev = "49e1c2b813b3e658a4c5a80f0df259840822336d";
    hash = "sha256-X/40bb90SYmJqxGwJ8bGd9Zq8Ylzf2fDtHHcTXHQ1DQ=";
  };

  # Скрипты ComfyUI (остаются как есть)
  startScript = pkgs.writeShellScript "start-comfyui" ''
    systemctl --user start comfyui
  '';

  stopScript = pkgs.writeShellScript "stop-comfyui" ''
    systemctl --user stop comfyui
  '';

  statusScript = pkgs.writeShellScript "status-comfyui" ''
    kitty --title "ComfyUI Status" bash -c "systemctl --user status comfyui; echo 'Press any key to close...'; read -n 1"
  '';

  # .desktop файлы
  startDesktop = pkgs.writeTextFile {
    name = "comfyui-start.desktop";
    destination = "/share/applications/comfyui-start.desktop";
    text = ''
      [Desktop Entry]
      Version=1.0
      Type=Application
      Name=Start ComfyUI
      Comment=Start ComfyUI server
      Exec=${startScript}
      Icon=applications-development
      Categories=Development;
      Terminal=false
      StartupNotify=false
    '';
  };

  stopDesktop = pkgs.writeTextFile {
    name = "comfyui-stop.desktop";
    destination = "/share/applications/comfyui-stop.desktop";
    text = ''
      [Desktop Entry]
      Version=1.0
      Type=Application
      Name=Stop ComfyUI
      Comment=Stop ComfyUI server
      Exec=${stopScript}
      Icon=applications-development
      Categories=Development;
      Terminal=false
      StartupNotify=false
    '';
  };

  statusDesktop = pkgs.writeTextFile {
    name = "comfyui-status.desktop";
    destination = "/share/applications/comfyui-status.desktop";
    text = ''
      [Desktop Entry]
      Version=1.0
      Type=Application
      Name=ComfyUI Status
      Comment=Show ComfyUI server status
      Exec=${statusScript}
      Icon=applications-development
      Categories=Development;
      Terminal=true
      StartupNotify=false
    '';
  };

in

{
  # Системный systemd-сервис для запуска ComfyUI. Запускается автоматически при загрузке (если включён wantedBy) или вручную systemctl start comfyui
  systemd.user.services.comfyui = {
    description = "ComfyUI server (user)";                                              # Описание сервиса (отображается в systemctl status)
    after = [ "network.target" ];                                                       # Запускать после того, как сеть поднята
    wantedBy = [];                                                                      # Не запускать при загрузке системы
  # wantedBy = [ "multi-user.target" ];                                                 # Автоматически запускать при загрузке системы

    serviceConfig = {
      Type = "simple";                                                                  # Тип сервиса (простой процесс, не разветвляется)
      WorkingDirectory = "${home}/.config/comfy-ui";                                    # Рабочая директория (где лежат модели и workflows)
      ExecStart = "${pkgs.comfy-ui-cuda}/bin/comfy-ui --listen 127.0.0.1 --port 8188 --enable-manager"; # Команда запуска - только локальный доступ
      Restart = "on-failure";                                                           # Перезапускать сервис, если он упал с ошибкой
      RestartSec = 5;                                                                   # Задержка перед перезапуском (5 секунд)
      DevicePolicy = "closed";                                                          # Разрешать только явно перечисленные устройства (безопасность)

      # ---------- Явное разрешение доступа к устройствам ----------
      DeviceAllow = [
        "/dev/fuse"                                                                     # Доступ к FUSE (для возможных монтирований внутри ComfyUI)
        "/dev/nvidia0"                                                                  # Основное устройство NVIDIA (видеокарта)
        "/dev/nvidiactl"                                                                # Управление NVIDIA
        "/dev/nvidia-uvm"                                                               # Unified Virtual Memory (нужен для CUDA)
        "/dev/nvidia-uvm-tools"                                                         # Инструменты UVM
        "/dev/nvidia-modeset"                                                           # Режимный сет (для Wayland)
        "char-drm"                                                                      # Доступ к DRM устройствам, systemd разворачивает в правила для card0, renderD128 и др.
      ];

      # ---------- Переменные окружения для CUDA и доступа к драйверу NVIDIA ----------
      Environment = [
        "CUDA_VISIBLE_DEVICES=0"                                                        # Использовать только первую видеокарту NVIDIA (GTX 3070)
        "LD_LIBRARY_PATH=/run/opengl-driver/lib:/run/opengl-driver/lib64"               # Путь к библиотекам драйвера NVIDIA
        "HOME=/home/${myLib.userName}"                                                  # Домашняя папка, необходима для ComfyUI (ищет .cache, .config)
      ];

      # ---------- Отключение ограничений systemd, мешающих работе с GPU и FUSE ----------
      PrivateDevices = false;                                                           # Разрешить доступ к устройствам (/dev/nvidia*, /dev/fuse)
      ProtectSystem = "off";                                                            # Отключить защиту системных каталогов (нужно для записи в /tmp и /run)
      ProtectHome = false;                                                              # Разрешить доступ к домашней папке (нужен ~/.cache, ~/.config)
      NoNewPrivileges = false;                                                          # Разрешить процессу получать новые привилегии (CAP_SYS_ADMIN)
      PrivateMounts = false;                                                            # Не изолировать точки монтирования (нужно для FUSE)
      MountFlags = "shared";                                                            # Сделать монтирования разделяемыми (необходимо для FUSE)
    };
  };

  # ========== Правила tmpfiles для папок монтирования ==========
  systemd.tmpfiles.rules = [
    # ---------- Скрипты ComfyUI в /mnt/ai/ ----------
    "L+ /mnt/ai/start-comfyui.sh - ${myLib.userName} ${myLib.userName} - ${startScript}"
    "L+ /mnt/ai/stop-comfyui.sh - ${myLib.userName} ${myLib.userName} - ${stopScript}"
    "L+ /mnt/ai/status-comfyui.sh - ${myLib.userName} ${myLib.userName} - ${statusScript}"

    # ---------- .desktop-файлы для меню KDE ----------
    "L+ ${home}/.local/share/applications/comfyui-start.desktop - ${myLib.userName} ${myLib.userName} - ${startDesktop}/share/applications/comfyui-start.desktop"
    "L+ ${home}/.local/share/applications/comfyui-stop.desktop - ${myLib.userName} ${myLib.userName} - ${stopDesktop}/share/applications/comfyui-stop.desktop"
    "L+ ${home}/.local/share/applications/comfyui-status.desktop - ${myLib.userName} ${myLib.userName} - ${statusDesktop}/share/applications/comfyui-status.desktop"

    # ---------- Директории ComfyUI в ~/.config/comfy-ui/ ----------
    "d ${home}/.config/comfy-ui/custom_nodes 0755 ${myLib.userName} ${myLib.userName} -"
    "d ${home}/.config/comfy-ui/models/diffusion_models 0755 ${myLib.userName} ${myLib.userName} -"
    "d ${home}/.config/comfy-ui/models/inpaint 0755 ${myLib.userName} ${myLib.userName} -"
    "d ${home}/.config/comfy-ui/models/loras 0755 ${myLib.userName} ${myLib.userName} -"
    "d ${home}/.config/comfy-ui/models/text_encoders 0755 ${myLib.userName} ${myLib.userName} -"
    "d ${home}/.config/comfy-ui/models/upscale_models 0755 ${myLib.userName} ${myLib.userName} -"
    "d ${home}/.config/comfy-ui/models/vae 0755 ${myLib.userName} ${myLib.userName} -"
    "d ${home}/.config/comfy-ui/models/checkpoints 0755 ${myLib.userName} ${myLib.userName} -"
    "d ${home}/.config/comfy-ui/models/audio_encoders 0755 ${myLib.userName} ${myLib.userName} -"

    # ---------- Директории на /mnt/ai (цели симлинков) ----------
    "d /mnt/ai/ComfyUI_output 0755 ${myLib.userName} ${myLib.userName} -"
    "d /mnt/ai/ComfyUI_models/default/text_encoders 0755 ${myLib.userName} ${myLib.userName} -"
    "d /mnt/ai/ComfyUI_models/yue2 0755 ${myLib.userName} ${myLib.userName} -"

    # ---------- input-output ----------
    "L+ /mnt/ai/ComfyUI_input - ${myLib.userName} ${myLib.userName} - ${home}/.config/comfy-ui/input"
    "L+ ${home}/.config/comfy-ui/output - ${myLib.userName} ${myLib.userName} - /mnt/ai/ComfyUI_output"

    # ============================== Krita ==============================
    "d /mnt/ai/ComfyUI_Krita-ai-diffusion 0755 ${myLib.userName} ${myLib.userName} -"
    "d /mnt/ai/ComfyUI_Krita-Vision-Tools 0755 ${myLib.userName} ${myLib.userName} -"

    # ---------- custom_nodes (плагины ComfyUI) ----------
    "L+ ${home}/.config/comfy-ui/custom_nodes/comfyui_controlnet_aux - ${myLib.userName} ${myLib.userName} - /mnt/ai/ComfyUI_Krita-ai-diffusion/comfyui_controlnet_aux" # Krita-ai-diffusion
    "L+ ${home}/.config/comfy-ui/custom_nodes/comfyui-inpaint-nodes - ${myLib.userName} ${myLib.userName} - /mnt/ai/ComfyUI_Krita-ai-diffusion/comfyui-inpaint-nodes" # Krita-ai-diffusion
    "L+ ${home}/.config/comfy-ui/custom_nodes/ComfyUI_IPAdapter_plus - ${myLib.userName} ${myLib.userName} - /mnt/ai/ComfyUI_Krita-ai-diffusion/ComfyUI_IPAdapter_plus" # Krita-ai-diffusion
    "L+ ${home}/.config/comfy-ui/custom_nodes/comfyui-tooling-nodes - ${myLib.userName} ${myLib.userName} - /mnt/ai/ComfyUI_Krita-ai-diffusion/comfyui-tooling-nodes" # Krita-ai-diffusion

    # ---------- Модели для Krita-ai-diffusion ----------
    "L+ ${home}/.config/comfy-ui/models/diffusion_models/flux-2-klein-4b-fp8.safetensors - ${myLib.userName} ${myLib.userName} - /mnt/ai/ComfyUI_Krita-ai-diffusion/models/diffusion_models/flux-2-klein-4b-fp8.safetensors" # Krita-ai-diffusion
    "L+ ${home}/.config/comfy-ui/models/diffusion_models/flux-2-klein-4b-Q6_K.gguf - ${myLib.userName} ${myLib.userName} - /mnt/ai/ComfyUI_Krita-ai-diffusion/models/diffusion_models/flux-2-klein-4b-Q6_K.gguf" # Krita-ai-diffusion
    "L+ ${home}/.config/comfy-ui/models/inpaint/MAT_Places512_G_fp16.safetensors - ${myLib.userName} ${myLib.userName} - /mnt/ai/ComfyUI_Krita-ai-diffusion/models/inpaint/MAT_Places512_G_fp16.safetensors" # Krita-ai-diffusion
    "L+ ${home}/.config/comfy-ui/models/loras/LyNiaZ53Tudg0J6sT8Xbx_pytorch_lora_weights_comfy_converted.safetensors - ${myLib.userName} ${myLib.userName} - /mnt/ai/ComfyUI_Krita-ai-diffusion/models/loras/LyNiaZ53Tudg0J6sT8Xbx_pytorch_lora_weights_comfy_converted.safetensors" # Krita-ai-diffusion
    "L+ ${home}/.config/comfy-ui/models/text_encoders/Qwen3-4B-Q4_K_M.gguf - ${myLib.userName} ${myLib.userName} - /mnt/ai/ComfyUI_Krita-ai-diffusion/models/text_encoders/Qwen3-4B-Q4_K_M.gguf" # Krita-ai-diffusion

    # ---------- Upscale модели ----------
    "L+ ${home}/.config/comfy-ui/models/upscale_models/4x_NMKD-Superscale-SP_178000_G.pth - ${myLib.userName} ${myLib.userName} - /mnt/ai/ComfyUI_Krita-ai-diffusion/models/upscale_models/4x_NMKD-Superscale-SP_178000_G.pth" # Krita-ai-diffusion
    "L+ ${home}/.config/comfy-ui/models/upscale_models/HAT_SRx4_ImageNet-pretrain.pth - ${myLib.userName} ${myLib.userName} - /mnt/ai/ComfyUI_Krita-ai-diffusion/models/upscale_models/HAT_SRx4_ImageNet-pretrain.pth" # Krita-ai-diffusion
    "L+ ${home}/.config/comfy-ui/models/upscale_models/OmniSR_X2_DIV2K.safetensors - ${myLib.userName} ${myLib.userName} - /mnt/ai/ComfyUI_Krita-ai-diffusion/models/upscale_models/OmniSR_X2_DIV2K.safetensors" # Krita-ai-diffusion
    "L+ ${home}/.config/comfy-ui/models/upscale_models/OmniSR_X3_DIV2K.safetensors - ${myLib.userName} ${myLib.userName} - /mnt/ai/ComfyUI_Krita-ai-diffusion/models/upscale_models/OmniSR_X3_DIV2K.safetensors" # Krita-ai-diffusion
    "L+ ${home}/.config/comfy-ui/models/upscale_models/OmniSR_X4_DIV2K.safetensors - ${myLib.userName} ${myLib.userName} - /mnt/ai/ComfyUI_Krita-ai-diffusion/models/upscale_models/OmniSR_X4_DIV2K.safetensors" # Krita-ai-diffusion
    "L+ ${home}/.config/comfy-ui/models/upscale_models/Real_HAT_GAN_sharper.pth - ${myLib.userName} ${myLib.userName} - /mnt/ai/ComfyUI_Krita-ai-diffusion/models/upscale_models/Real_HAT_GAN_sharper.pth" # Krita-ai-diffusion
    "L+ ${home}/.config/comfy-ui/models/vae/flux2-vae.safetensors - ${myLib.userName} ${myLib.userName} - /mnt/ai/ComfyUI_Krita-ai-diffusion/models/vae/flux2-vae.safetensors" # Krita-ai-diffusion

    # ============================== ComfyUI ==============================
    # ---------- custom_nodes (плагины ComfyUI) ----------
    "L+ ${home}/.config/comfy-ui/custom_nodes/NStor-ComfyUI-Translation - ${myLib.userName} ${myLib.userName} - ${nstor-translation}" # NStor-ComfyUI-Translation (локализация интерфейса)

    # ---------- Модели для ComfyUI ----------
    "L+ ${home}/.config/comfy-ui/models/text_encoders/qwen_3_4b_fp4_flux2.safetensors - ${myLib.userName} ${myLib.userName} - /mnt/ai/ComfyUI_models/default/text_encoders/qwen_3_4b_fp4_flux2.safetensors" # default (Text encoder для Flux-2-Klein)
    "L+ ${home}/.config/comfy-ui/models/checkpoints/yue2_3b_int8_convrot.safetensors - ${myLib.userName} ${myLib.userName} - /mnt/ai/ComfyUI_models/yue2/yue2_3b_int8_convrot.safetensors" # Yue (Yue2) music model
    "L+ ${home}/.config/comfy-ui/models/audio_encoders/sheetsage2_bf16.safetensors - ${myLib.userName} ${myLib.userName} - /mnt/ai/ComfyUI_models/yue2/sheetsage2_bf16.safetensors" # Yue (Yue2) audio encoder
  ];
}
