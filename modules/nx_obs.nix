{ pkgs, ... }:

{
  environment.systemPackages = [
    (pkgs.obs-studio.override { cudaSupport = true; })   # Основной пакет OBS с поддержкой CUDA (NVENC)

    pkgs.obs-studio-plugins.wlrobs                       # Захват экрана под Wayland (wlroots-based)
    pkgs.obs-studio-plugins.obs-vaapi                    # Аппаратное кодирование через VA-API (для Intel/AMD)
    pkgs.obs-studio-plugins.obs-pipewire-audio-capture   # Захват звука через PipeWire
    pkgs.obs-studio-plugins.obs-multi-rtmp               # Мультистриминг на несколько платформ одновременно
    pkgs.obs-studio-plugins.obs-backgroundremoval        # Удаление фона без зелёного экрана
    pkgs.obs-studio-plugins.obs-vintage-filter           # Винтажные видеоэффекты
    pkgs.obs-studio-plugins.obs-source-clone             # Клонирование источников с разными фильтрами
  ];
}
