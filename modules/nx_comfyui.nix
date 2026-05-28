# modules/nx_comfyui.nix
# Модуль для настройки системного сервиса ComfyUI через flake utensils/comfyui-nix
{ config, pkgs, myLib, lib, ... }:   # lib добавлен для lib.mkForce

{
  # Основная конфигурация сервиса ComfyUI
  services.comfyui = {
    enable = true;                                # Включить сервис (создать systemd unit)
    gpuSupport = "cuda";                          # Использовать сборку для NVIDIA (RTX 3070)
    enableManager = true;                         # Включить встроенный ComfyUI Manager (установка кастомных нод)
    port = 8188;                                  # Порт, на котором будет доступен веб-интерфейс
    listenAddress = "127.0.0.1";                  # Слушать только локальный интерфейс
    dataDir = "/mnt/ai/ComfyUI";                  # Путь к данным: модели, выходные изображения, пользовательские ноды
    openFirewall = true;                          # Открыть порт 8188 в фаерволе (если нужно с других устройств)
    extraArgs = [ "--lowvram" ];                  # Флаг для видеокарт с 8 ГБ VRAM (экономит память)
    user = "lucerno";                             # Запускать сервис от пользователя
    group = "lucerno";                            # Группа пользователя
    createUser = false;                           # Не создавать системного пользователя — используем существующего

    extraPackages = with pkgs.comfyuiPackages; [  # Включаем недостающие кастомные ноды
      comfyui-controlnet-aux                      # ControlNet Preprocessors
      comfyui-ipadapter-plus                      # IP-Adapter
      comfyui-tooling-nodes                       # External Tooling Nodes
      comfyui-inpaint-nodes                       # Inpaint Nodes
    ];
  };

  # Отключаем автоматический запуск сервиса при загрузке системы.
  # Без этой строки сервис запускался бы автоматически (wantedBy = [ "multi-user.target" ]).
  # lib.mkForce [] переопределяет стандартное значение wantedBy на пустой список,
  # что означает: сервис не будет запущен автоматически, но останется доступен для ручного управления.
  systemd.services.comfyui.wantedBy = lib.mkForce [];
}
