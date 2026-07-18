{ pkgs, ... }:

let
  obs = pkgs.obs-studio.override { cudaSupport = true; }; # Основной пакет OBS с поддержкой CUDA (NVENC)
  pluginList = with pkgs.obs-studio-plugins; [            # Список плагинов
    wlrobs                                                # Захват экрана под Wayland (wlroots-based)
    obs-vaapi                                             # Аппаратное кодирование через VA-API (для Intel/AMD)
    obs-pipewire-audio-capture                            # Захват звука через PipeWire
    obs-multi-rtmp                                        # Мультистриминг на несколько платформ одновременно
    obs-backgroundremoval                                 # Удаление фона без зелёного экрана
    obs-vintage-filter                                    # Винтажные фильтры
    obs-source-clone                                      # Клонирование источников с разными фильтрами
  ];

  # Объединяем OBS и плагины в один пакет
  obsWithPlugins = pkgs.symlinkJoin {
    name = "obs-studio-with-plugins";
    paths = [ obs ] ++ pluginList;
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      # Создаём каталог для плагинов
      mkdir -p $out/lib/obs-plugins
      # Копируем плагины из каждого пакета
      for p in ${toString pluginList}; do
        if [ -d "$p/lib/obs-plugins" ]; then
          ln -sf $p/lib/obs-plugins/* $out/lib/obs-plugins/
        fi
      done
      # Оборачиваем бинарник, чтобы OBS знал, где искать плагины
      wrapProgram $out/bin/obs-studio \
        --set OBS_PLUGINS_PATH "$out/lib/obs-plugins"
    '';
  };

in {
  environment.systemPackages = [ obsWithPlugins ];        # Добавляем собранный пакет в системные
}
