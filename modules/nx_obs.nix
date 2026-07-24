{ pkgs, ... }:

{
  programs.obs-studio = {
    enable = true;                                                 # Включает поддержку OBS
    package = pkgs.obs-studio.override { cudaSupport = true; };    # Основной пакет с CUDA
    enableVirtualCamera = true;                                    # Включает виртуальную веб-камеру (v4l2loopback)
    plugins = with pkgs.obs-studio-plugins; [                      # Подключение плагинов
      wlrobs                                                       # Захват экрана под Wayland
      obs-vaapi                                                    # Аппаратное кодирование через VA-API
      obs-pipewire-audio-capture                                   # Захват звука через PipeWire
      obs-multi-rtmp                                               # Мультистриминг
      obs-backgroundremoval                                        # Удаление фона
      obs-vintage-filter                                           # Винтажные эффекты
      obs-source-clone                                             # Клонирование источников
    ];
  };
}
