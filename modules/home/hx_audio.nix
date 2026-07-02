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
    };
  };

  # ========== Настройка приоритетов реального времени для PipeWire и WirePlumber ==========

  # Демон PipeWire (основной аудио-сервер)
  systemd.user.services.pipewire = {
    serviceConfig = {
      CPUSchedulingPolicy = "fifo";        # Политика планирования FIFO (режим реального времени)
      CPUSchedulingPriority = 85;          # Приоритет (чем выше, тем важнее)
      Nice = -11;                          # Отрицательный nice даёт более высокий приоритет
      LimitRTPRIO = "89";                  # Максимальный допустимый приоритет RT
    };
  };

  # Демон PipeWire-Pulse (эмуляция PulseAudio для совместимости)
  systemd.user.services.pipewire-pulse = {
    serviceConfig = {
      CPUSchedulingPolicy = "fifo";        # Политика планирования FIFO (режим реального времени)
      CPUSchedulingPriority = 85;          # Приоритет (чем выше, тем важнее)
      Nice = -11;                          # Отрицательный nice даёт более высокий приоритет
      LimitRTPRIO = "89";                  # Максимальный допустимый приоритет RT
    };
  };

  # Менеджер сессий WirePlumber (управляет маршрутизацией и устройствами)
  systemd.user.services.wireplumber = {
    serviceConfig = {
      CPUSchedulingPolicy = "fifo";        # Политика планирования FIFO (режим реального времени)
      CPUSchedulingPriority = 85;          # Приоритет (чем выше, тем важнее)
      Nice = -11;                          # Отрицательный nice даёт более высокий приоритет
      LimitRTPRIO = "89";                  # Максимальный допустимый приоритет RT
    };
  };
}
