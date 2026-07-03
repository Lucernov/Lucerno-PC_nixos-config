{ pkgs-unstable, lib, ... }:
{
  home = {
    # Активационные скрипты (выполняются при каждом переключении поколения Home Manager)
    activation = {
      # Создаёт символическую ссылку wine64 в ~/.local/bin, чтобы winetricks не ругался на отсутствие wine64
      createWine64Link = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        mkdir -p $HOME/.local/bin
        ln -sf ${pkgs-unstable.wineWow64Packages.staging}/bin/wine $HOME/.local/bin/wine64
      '';
      # Создаёт каталог ~/.vst3 для пользовательских VST-плагинов (стандартная папка для VST3)
      createVst3Dir = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        mkdir -p $HOME/.vst3
      '';
    };

    # Пользовательские файлы (конфигурация REAPER)
    file = {
      # Копирует библиотеку расширения SWS в папку UserPlugins REAPER (автоматически подгружается)
      ".config/REAPER/UserPlugins/reaper_sws-x86_64.so".source = "${pkgs-unstable.reaper-sws-extension}/UserPlugins/reaper_sws-x86_64.so";
      # Копирует библиотеку расширения ReaPack в папку UserPlugins REAPER
      ".config/REAPER/UserPlugins/reaper_reapack-x86_64.so".source = "${pkgs-unstable.reaper-reapack-extension}/UserPlugins/reaper_reapack-x86_64.so";


      # ========== Настройка приоритетов реального времени для PipeWire и WirePlumber ==========

      # Drop‑in файлы для приоритетов реального времени (безопасный способ)
      # Эти файлы добавляют настройки к системным юнитам, не переопределяя их полностью.
      ".config/systemd/user/pipewire.service.d/99-realtime.conf".text = ''
        [Service]
        CPUSchedulingPolicy=fifo
        CPUSchedulingPriority=85
        Nice=-11
        LimitRTPRIO=89
      '';
      ".config/systemd/user/pipewire-pulse.service.d/99-realtime.conf".text = ''
        [Service]
        CPUSchedulingPolicy=fifo
        CPUSchedulingPriority=85
        Nice=-11
        LimitRTPRIO=89
      '';
      ".config/systemd/user/wireplumber.service.d/99-realtime.conf".text = ''
        [Service]
        CPUSchedulingPolicy=fifo
        CPUSchedulingPriority=85
        Nice=-11
        LimitRTPRIO=89
      '';
    };
  };
}
