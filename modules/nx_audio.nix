{ pkgs, pkgs-unstable, lib, myLib, ... }:

let
  commonRealtime = {
    CPUSchedulingPolicy = "fifo";                                                   # SCHED_FIFO — планировщик RT
    CPUSchedulingPriority = 85;                                                     # RT-приоритет, иерархия RT-приоритетов 85 control / 88 data / 89 limit
    Nice = -11;                                                                     # nice для не-RT частей
    LimitRTPRIO = 89;                                                               # жёсткий лимит RT (совпадает с pam.loginLimits)
    NoNewPrivileges = false;                                                        # разрешить менять приоритеты
  };

  # Собирает путь к плагинам: /run/current-system/sw/lib/<format>:$HOME/.<format>
  pluginPath = format: lib.makeSearchPath format [
    "/run/current-system/sw/lib"
  ] + ":${myLib.home}/.${format}";
in

{
  environment.sessionVariables = {
    CLAP_PATH   = pluginPath "clap";    # Установить переменную окружения для пользовательской папки CLAP
    LV2_PATH    = pluginPath "lv2";     # Установить переменную окружения для пользовательской папки LV2
    VST_PATH    = pluginPath "vst";     # Установить переменную окружения для пользовательской папки VST
    VST3_PATH   = pluginPath "vst3";    # Установить переменную окружения для пользовательской папки VST3
    LXVST_PATH  = pluginPath "lxvst";   # Установить переменную окружения для пользовательской папки LXVST (Linux VST — устаревший формат)
    LADSPA_PATH = pluginPath "ladspa";  # Установить переменную окружения для пользовательской папки LADSPA (простой формат эффектов)
    DSSI_PATH   = pluginPath "dssi";    # Установить переменную окружения для пользовательской папки DSSI (инструменты на базе LADSPA)
  };

  services = {
    pulseaudio.enable = false;                                                      # Отключить старый звуковой сервер PulseAudio (полностью заменяем на PipeWire)
    pipewire = {                                                                    # Основные настройки PipeWire
      enable = true;                                                                # Включить PipeWire как основной звуковой сервер
      alsa.enable = true;                                                           # Поддержка ALSA (эмуляция для старых приложений)
      alsa.support32Bit = true;                                                     # Поддержка 32-битных ALSA-клиентов (для игр и старого софта)
      jack.enable = true;                                                           # JACK-совместимость (PipeWire как JACK-сервер)
      pulse.enable = true;                                                          # Включить pipewire-pulse — эмуляцию сервера PulseAudio поверх PipeWire
      wireplumber.enable = true;                                                    # WirePlumber — менеджер сессий для PipeWire (более современный, чем старый media-session)
      extraLv2Packages = with pkgs; [                                               # Позволяет PipeWire загружать LV2-плагины как filter-chain (обработка сигнала на уровне звукового сервера, а не в DAW).
        lsp-plugins                                                                 # Набор LSP: EQ, компрессоры, лимитеры, meters
        noise-repellent                                                             # Нейро шумодав для голоса Real-time
      ];
      extraConfig = {
        # ---------- Основные параметры контекста PipeWire ----------
        pipewire."99-low-latency" = {
          "context.properties" = {
            "default.clock.allowed-rates" = [ 44100 48000 ];                        # Разрешённые частоты дискретизации
            "default.clock.rate" = 48000;                                           # Частота дискретизации по умолчанию (48 кГц)
            "default.clock.quantum" = 512;                                          # Буфер по умолчанию для приложений, которые не задают его сами (браузер, игры, плееры) — ~10,6 мс при 48 кГц
            "default.clock.min-quantum" = 64;                                       # Минимальный буфер, который может запросить приложение (REAPER через ALSA выставлен в 64) — ~1,3 мс при 48 кГц
            "default.clock.max-quantum" = 2048;                                     # Максимальный буфер для тяжёлых приложений — ~42,7 мс, страховка от xrun
          };
        };
        # --- RT-приоритеты для клиентов (REAPER через ALSA) ---
        client."99-reaper-rt" = {
          "context.modules" = [{
            name = "libpipewire-module-rt";                                         # Модуль реального времени: выдаёт клиентам RT-приоритеты через rtkit/RLIMIT_RTPRIO
            args = {
              "rt.prio" = 88;                                                       # RT-приоритет для data thread (поток обработки аудио, напр. reaper/audio)
              "nice.level" = -11;                                                   # nice для application thread (вспомогательный поток клиента)
            };
            flags = [ "ifexists" "nofail" ];                                        # ifexists — не падать, если модуль не найден; nofail — не считать ошибкой, если модуль не загрузился
          }];
        };
      };
    };
  };

  # ========== Настройка приоритетов реального времени для PipeWire и WirePlumber ==========
  security = {
    rtkit.enable = true;                                                            # Включить rtkit (Realtime Kit) — демон, дающий процессам приоритет реального времени. Необходим для низких задержек в аудио.
    pam.loginLimits = [                                                             # Лимиты для аудио-группы (чтобы приложения имели приоритет реального времени и блокировку памяти)
      { domain = "@audio"; item = "rtprio"; type = "soft"; value = "89"; }          # мягкий лимит RT-приоритета
      { domain = "@audio"; item = "rtprio"; type = "hard"; value = "89"; }          # жёсткий лимит RT-приоритета
      { domain = "@audio"; item = "memlock"; type = "soft"; value = "unlimited"; }  # мягкий лимит блокировки памяти
      { domain = "@audio"; item = "memlock"; type = "hard"; value = "unlimited"; }  # жёсткий лимит блокировки памяти
      { domain = "@audio"; item = "nice"; type = "soft"; value = "-11"; }           # разрешить nice -11
      { domain = "@audio"; item = "nice"; type = "hard"; value = "-11"; }           # жёсткий лимит nice
      { domain = "@audio"; item = "nofile"; type = "soft"; value = "99999"; }       # мягкий лимит открытых файловых дескрипторов (для проектов с сотнями сэмплов и плагинов)
      { domain = "@audio"; item = "nofile"; type = "hard"; value = "99999"; }       # жёсткий лимит открытых файловых дескрипторов
    ];
  };

  # ========== RT-приоритеты для PipeWire (см. commonRealtime в let-блоке) ==========
  systemd.user.services = {
    pipewire.serviceConfig = commonRealtime;
    pipewire-pulse.serviceConfig = commonRealtime;
    wireplumber.serviceConfig = commonRealtime;
  };

  # u-he TripleCheese — writeable-раскладка в домашние папки
  # Логика установки живёт в pkg_Triple-Cheese.nix (passthru.installScript)
  # Модуль только дёргает скрипт с параметрами: src, home, user
  system.activationScripts.triplecheese = {
    supportsDryActivation = true;
    text = ''
      ${pkgs.lucerno-packages.triplecheese.installScript} \
        ${pkgs.lucerno-packages.triplecheese} \
        ${myLib.home} \
        ${myLib.userName}
    '';
  };

  systemd.tmpfiles.rules = [                                                        # Правила tmpfiles
    # ========== Правила tmpfiles для аудио и REAPER ==========
    "d ${myLib.home}/.clap 0755 ${myLib.userName} ${myLib.userName} -"
    "d ${myLib.home}/.lv2 0755 ${myLib.userName} ${myLib.userName} -"
    "d ${myLib.home}/.vst 0755 ${myLib.userName} ${myLib.userName} -"
    "d ${myLib.home}/.vst3 0755 ${myLib.userName} ${myLib.userName} -"
    "d ${myLib.home}/.lxvst 0755 ${myLib.userName} ${myLib.userName} -"
    "d ${myLib.home}/.ladspa 0755 ${myLib.userName} ${myLib.userName} -"
    "d ${myLib.home}/.dssi 0755 ${myLib.userName} ${myLib.userName} -"
    "L+ ${myLib.home}/.config/REAPER - ${myLib.userName} ${myLib.userName} - ${myLib.home}/${myLib.configDirName}/dotfiles/config/REAPER"
    "d ${myLib.home}/${myLib.configDirName}/dotfiles/config/REAPER/UserPlugins 0755 ${myLib.userName} ${myLib.userName} -"
    "L+ ${myLib.home}/${myLib.configDirName}/dotfiles/config/REAPER/UserPlugins/reaper_sws-x86_64.so - ${myLib.userName} ${myLib.userName} - ${pkgs-unstable.reaper-sws-extension}/UserPlugins/reaper_sws-x86_64.so"  # .so файлы REAPER
    "L+ ${myLib.home}/${myLib.configDirName}/dotfiles/config/REAPER/UserPlugins/reaper_reapack-x86_64.so - ${myLib.userName} ${myLib.userName} - ${pkgs-unstable.reaper-reapack-extension}/UserPlugins/reaper_reapack-x86_64.so"  # .so файлы REAPER
    "L+ ${myLib.home}/.local/bin/wine64 - ${myLib.userName} ${myLib.userName} - ${pkgs.wineWow64Packages.staging}/bin/wine"  # wine64
    "L+ /usr/bin/zenity - - - - ${pkgs.zenity}/bin/zenity" # нужно для работы вывода меню выбора пресетов внутри плагина

    # ---------- Структура каталогов для данных Amp Locker и Drum Locker ----------
    "d \"${myLib.home}/Audio Assault\" 0755 ${myLib.userName} ${myLib.userName} -"
    "d \"${myLib.home}/Audio Assault/PluginData\" 0755 ${myLib.userName} ${myLib.userName} -"
    "d \"${myLib.home}/Audio Assault/PluginData/Audio Assault\" 0755 ${myLib.userName} ${myLib.userName} -"
    "L+ \"${myLib.home}/Audio Assault/PluginData/Audio Assault/AmpLockerData\" - ${myLib.userName} ${myLib.userName} - /run/current-system/sw/share/amp-locker"
    "L+ \"${myLib.home}/Audio Assault/PluginData/Audio Assault/DrumLockerData\" - ${myLib.userName} ${myLib.userName} - /run/current-system/sw/share/drum-locker"

    # ---------- Mulhacen: factory-ресурсы из деривации ----------
    # Плагин ищет IRS-импульсы и .nam-модели в $XDG_DATA_HOME/Mulhacen/factory. Пробрасываем симлинк на $out/share/Mulhacen/factory из pkg_Mulhacen.nix.
    "d ${myLib.home}/.local/share/Mulhacen 0755 ${myLib.userName} ${myLib.userName} -"
    "L+ ${myLib.home}/.local/share/Mulhacen/factory - ${myLib.userName} ${myLib.userName} - ${pkgs.lucerno-packages.mulhacen-clap}/share/Mulhacen/factory"

    # ---------- Симлинки конфигов плагинов ----------
    "L+ ${myLib.home}/.config/yabridgectl - ${myLib.userName} ${myLib.userName} - ${myLib.home}/${myLib.configDirName}/dotfiles/config/yabridgectl"
    "L+ ${myLib.home}/.config/DecentSampler - ${myLib.userName} ${myLib.userName} - /mnt/sys_archiv/samples/DecentSampler"
    "L+ \"${myLib.home}/.config/Amp Locker\" - ${myLib.userName} ${myLib.userName} - ${myLib.home}/${myLib.configDirName}/dotfiles/config/plugins/config_Amp Locker"
    "L+ \"${myLib.home}/.config/Audio Assault\" - ${myLib.userName} ${myLib.userName} - ${myLib.home}/${myLib.configDirName}/dotfiles/config/plugins/config_Audio Assault"
    "L+ ${myLib.home}/.config/geonkick - ${myLib.userName} ${myLib.userName} - ${myLib.home}/${myLib.configDirName}/dotfiles/config/plugins/config_geonkick"
    "L+ ${myLib.home}/.config/lsp-plugins - ${myLib.userName} ${myLib.userName} - ${myLib.home}/${myLib.configDirName}/dotfiles/config/plugins/config_lsp-plugins"
    "L+ ${myLib.home}/.config/3VStudio - ${myLib.userName} ${myLib.userName} - ${myLib.home}/${myLib.configDirName}/dotfiles/config/plugins/config_3VStudio"
    "L+ \"${myLib.home}/.config/My Company\" - ${myLib.userName} ${myLib.userName} - ${myLib.home}/${myLib.configDirName}/dotfiles/config/plugins/config_My Company"
    "L+ ${myLib.home}/.config/MANDA_AUDIO - ${myLib.userName} ${myLib.userName} - ${myLib.home}/${myLib.configDirName}/dotfiles/config/plugins/config_MANDA_AUDIO"
    "L+ ${myLib.home}/.config/Plogue - ${myLib.userName} ${myLib.userName} - ${myLib.home}/${myLib.configDirName}/dotfiles/config/plugins/config_Plogue"
    "L+ ${myLib.home}/.local/share/geonkick - ${myLib.userName} ${myLib.userName} - ${myLib.home}/${myLib.configDirName}/dotfiles/config/plugins/local_share_geonkick"
    "L+ ${myLib.home}/${myLib.configDirName}/dotfiles/config/plugins/local_share_geonkick/presets - ${myLib.userName} ${myLib.userName} - /run/current-system/sw/share/geonkick/presets"
    "L+ \"${myLib.home}/.local/share/The Usual Suspects\" - ${myLib.userName} ${myLib.userName} - ${myLib.home}/${myLib.configDirName}/dotfiles/config/plugins/local_share_The Usual Suspects"
    "L+ ${myLib.home}/.local/share/vital - ${myLib.userName} ${myLib.userName} - /mnt/sys_archiv/samples/vital"
    "L+ ${myLib.home}/drum_sklad - ${myLib.userName} ${myLib.userName} - /mnt/sys_archiv/samples/drum_sklad"
  ];

}

# Системные пути для плагинов
# CLAP - /run/current-system/sw/lib/clap/
# LV2  - /run/current-system/sw/lib/lv2/
# VST2 - /run/current-system/sw/lib/vst/
# VST3 - /run/current-system/sw/lib/vst3/
#
# rt.time.soft и rt.time.hard не применяются в PipeWire 1.6.6 из-за несовместимости форматов NixOS JSON и SPA-JSON
# Система использует значения по умолчанию (-1), что означает отсутствие лимитов на CPU-время для RT-потоков
