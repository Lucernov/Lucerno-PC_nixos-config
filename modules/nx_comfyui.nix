{ pkgs, myLib, ... }:

{
  # Системный systemd-сервис для запуска ComfyUI. Запускается автоматически при загрузке (если включён wantedBy) или вручную systemctl start comfyui
  systemd.services.comfyui = {
    description = "ComfyUI server (system)";                                            # Описание сервиса (отображается в systemctl status)
    after = [ "network.target" ];                                                       # Запускать после того, как сеть поднята
    wantedBy = [ "multi-user.target" ];                                                 # Автоматически запускать при загрузке системы
    serviceConfig = {
      User = myLib.userName;                                                            # Запускать от имени пользователя lucerno (не от root)
      Group = myLib.userName;                                                           # Группа пользователя
      Type = "simple";                                                                  # Тип сервиса (простой процесс, не разветвляется)
      WorkingDirectory = "/mnt/ai/ComfyUI";                                             # Рабочая директория (где лежат модели и workflows)
      ExecStart = "${pkgs.comfy-ui-cuda}/bin/comfy-ui --listen 127.0.0.1 --port 8188";  # Команда запуска - только локальный доступ
      Restart = "on-failure";                                                           # Перезапускать сервис, если он упал с ошибкой
      RestartSec = 5;                                                                   # Задержка перед перезапуском (5 секунд)

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

      # ---------- Дополнительные группы для доступа к оборудованию ----------
      SupplementaryGroups = [ "fuse" "render" "video" "nvidia" ];                       # Группы для доступа к FUSE, GPU, NVIDIA

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
      DevicePolicy = "closed";                                                          # Разрешать только явно перечисленные устройства (безопасность)
      AmbientCapabilities = [ "CAP_SYS_ADMIN" ];                                        # Дать процессу возможность монтировать (нужно для FUSE)
    };
  };
}
