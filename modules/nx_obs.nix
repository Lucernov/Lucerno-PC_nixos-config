{ config, pkgs, ... }:
{
  # Настройка OBS Studio через home-manager
  programs.obs-studio = {
    enable = true;                                                 # Включает модуль OBS Studio в home-manager

    package = pkgs.obs-studio.override { cudaSupport = true; };    # Пакет OBS Studio с поддержкой CUDA (NVENC для NVIDIA)

    plugins = with pkgs.obs-studio-plugins; [                      # Список устанавливаемых плагинов OBS Studio
      wlrobs                                                       # Захват экрана под Wayland (wlroots-based)
      obs-vaapi                                                    # Аппаратное кодирование через VA-API (для Intel/AMD)
      obs-pipewire-audio-capture                                   # Захват звука через PipeWire
      obs-multi-rtmp                                               # Мультистриминг на несколько платформ одновременно
      obs-backgroundremoval                                        # Удаление фона без зелёного экрана
      obs-vintage-filter                                           # Винтажные видеоэффекты
      obs-source-clone                                             # Клонирование источников с разными фильтрами
    ];
  };
}
