# systemctl --user daemon-reload - перезагрузка сервисов
# systemctl --user restart comfyui - перезагрузка comfyui
# systemctl --user status comfyui - вывод статуса comfyui
{ pkgs, myLib, ... }:

let
  inherit (myLib) home;

  # Скрипты ComfyUI (остаются как есть)
  startScript = pkgs.writeShellScript "start-comfyui" ''
    #!/usr/bin/env bash
    systemctl --user start comfyui
    echo "ComfyUI server started"
  '';

  stopScript = pkgs.writeShellScript "stop-comfyui" ''
    #!/usr/bin/env bash
    systemctl --user stop comfyui
    echo "ComfyUI server stopped"
  '';

  statusScript = pkgs.writeShellScript "status-comfyui" ''
    #!/usr/bin/env bash
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
      Categories=Development;System;
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
      Categories=Development;System;
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
      Categories=Development;System;
      Terminal=true   # запускаем в терминале, чтобы видеть статус
      StartupNotify=false
    '';
  };

in

{
  # Системный systemd-сервис для запуска ComfyUI. Запускается автоматически при загрузке (если включён wantedBy) или вручную systemctl start comfyui
  systemd.user.services.comfyui = {
    description = "ComfyUI server (user)";                                            # Описание сервиса (отображается в systemctl status)
    after = [ "network.target" ];                                                       # Запускать после того, как сеть поднята
    wantedBy = [];                                                                      # Не запускать при загрузке системы
  # wantedBy = [ "multi-user.target" ];                                                 # Автоматически запускать при загрузке системы

    serviceConfig = {
    # User = myLib.userName;                                                            # Запускать от имени пользователя lucerno (не от root)
    # Group = myLib.userName;                                                           # Группа пользователя
      Type = "simple";                                                                  # Тип сервиса (простой процесс, не разветвляется)
      WorkingDirectory = "/mnt/ai/ComfyUI";                                             # Рабочая директория (где лежат модели и workflows)
      ExecStart = "${pkgs.comfy-ui-cuda}/bin/comfy-ui --listen 127.0.0.1 --port 8188";  # Команда запуска - только локальный доступ
      Restart = "on-failure";                                                           # Перезапускать сервис, если он упал с ошибкой
      RestartSec = 5;                                                                   # Задержка перед перезапуском (5 секунд)
      DevicePolicy = "closed";                                                          # Разрешать только явно перечисленные устройства (безопасность)
    # AmbientCapabilities = [ "CAP_SYS_ADMIN" ];                                        # Дать процессу возможность монтировать (нужно для FUSE)

      # ---------- Явное разрешение доступа к устройствам ----------
      DeviceAllow = [
        "/dev/fuse"                                                                     # Доступ к FUSE (для возможных монтирований внутри ComfyUI)
        "/dev/nvidia0"                                                                  # Основное устройство NVIDIA (видеокарта)
        "/dev/nvidiactl"                                                                # Управление NVIDIA
        "/dev/nvidia-uvm"                                                               # Unified Virtual Memory (нужен для CUDA)
        "/dev/nvidia-uvm-tools"                                                         # Инструменты UVM
        "/dev/nvidia-modeset"                                                           # Режимный сет (для Wayland)
        "/dev/dri/*"                                                                    # Доступ к DRI (графика)
      ];

      # ---------- Переменные окружения для CUDA и доступа к драйверу NVIDIA ----------
      Environment = [
        "CUDA_VISIBLE_DEVICES=0"                                                        # Использовать только первую видеокарту NVIDIA (GTX 3070)
        "LD_LIBRARY_PATH=/run/opengl-driver/lib:/run/opengl-driver/lib64"               # Путь к библиотекам драйвера NVIDIA
        "HOME=/home/lucerno"                                                            # Домашняя папка, необходима для ComfyUI (ищет .cache, .config)
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
    # ---------- Симлинки скриптов ComfyUI в /mnt/ai/ ----------
    "L+ /mnt/ai/start-comfyui.sh - lucerno lucerno - ${startScript}"
    "L+ /mnt/ai/stop-comfyui.sh - lucerno lucerno - ${stopScript}"
    "L+ /mnt/ai/status-comfyui.sh - lucerno lucerno - ${statusScript}"
    # Симлинки для .desktop файлов
    "L+ ${home}/.local/share/applications/comfyui-start.desktop - lucerno lucerno - ${startDesktop}/share/applications/comfyui-start.desktop"
    "L+ ${home}/.local/share/applications/comfyui-stop.desktop - lucerno lucerno - ${stopDesktop}/share/applications/comfyui-stop.desktop"
    "L+ ${home}/.local/share/applications/comfyui-status.desktop - lucerno lucerno - ${statusDesktop}/share/applications/comfyui-status.desktop"

    # линки ComfyUI
    "d /mnt/ai/ComfyUI/custom_nodes 0755 lucerno lucerno -"
    "d /mnt/ai/ComfyUI/models/diffusion_models 0755 lucerno lucerno -"
    "d /mnt/ai/ComfyUI/models/inpaint 0755 lucerno lucerno -"
    "d /mnt/ai/ComfyUI/models/loras 0755 lucerno lucerno -"
    "d /mnt/ai/ComfyUI/models/text_encoders 0755 lucerno lucerno -"
    "d /mnt/ai/ComfyUI/models/upscale_models 0755 lucerno lucerno -"
    "d /mnt/ai/ComfyUI/models/vae 0755 lucerno lucerno -"

    # ---------- Симлинки ComfyUI (в /mnt/ai) ----------
    "L+ ${home}/.config/comfy-ui - lucerno lucerno - /mnt/ai/ComfyUI"
    "L+ /mnt/ai/ComfyUI/custom_nodes/comfyui_controlnet_aux - lucerno lucerno - /mnt/ai/ComfyUI_krita-ai-diffusion/comfyui_controlnet_aux"
    "L+ /mnt/ai/ComfyUI/custom_nodes/comfyui-inpaint-nodes - lucerno lucerno - /mnt/ai/ComfyUI_krita-ai-diffusion/comfyui-inpaint-nodes"
    "L+ /mnt/ai/ComfyUI/custom_nodes/ComfyUI_IPAdapter_plus - lucerno lucerno - /mnt/ai/ComfyUI_krita-ai-diffusion/ComfyUI_IPAdapter_plus"
    "L+ /mnt/ai/ComfyUI/custom_nodes/comfyui-tooling-nodes - lucerno lucerno - /mnt/ai/ComfyUI_krita-ai-diffusion/comfyui-tooling-nodes"

    # Модели
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
  ];
}
