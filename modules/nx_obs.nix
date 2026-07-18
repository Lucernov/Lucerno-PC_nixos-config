{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    (obs-studio.override { cudaSupport = true; })         # OBS с поддержкой NVENC
  ] ++ (with pkgs.obs-studio-plugins; [
    wlrobs                                                # Захват экрана под Wayland (wlroots-based)
    obs-vaapi                                             # Аппаратное кодирование через VA-API (для Intel/AMD)
    obs-pipewire-audio-capture                            # Захват звука через PipeWire
    obs-multi-rtmp                                        # Мультистриминг на несколько платформ одновременно
    obs-backgroundremoval                                 # Удаление фона без зелёного экрана
    obs-vintage-filter                                    # Винтажные фильтры
    obs-source-clone                                      # Клонирование источников с разными фильтрами
  ]);
}
