{ pkgs, pkgs-unstable, myLib, ... }:

let
  commonRealtime = {
    CPUSchedulingPolicy = "fifo";                                                                       # SCHED_FIFO — планировщик RT
    CPUSchedulingPriority = 85;                                                                         # RT-приоритет, выровнена иерархия RT-приоритетов (85 control / 88 data / 89 limit)
    Nice = -11;                                                                                         # nice для не-RT частей
    LimitRTPRIO = 89;                                                                                   # жёсткий лимит RT (совпадает с pam.loginLimits)
    NoNewPrivileges = false;                                                                            # разрешаем менять приоритеты
  };
in

{
  environment.sessionVariables = {
    CLAP_PATH   = "/run/current-system/sw/lib/clap:${myLib.home}/.clap";                                # Устанавливаем переменную окружения для пользовательской папки CLAP
    LV2_PATH    = "/run/current-system/sw/lib/lv2:${myLib.home}/.lv2";                                  # Устанавливаем переменную окружения для пользовательской папки LV2
    VST_PATH    = "/run/current-system/sw/lib/vst:${myLib.home}/.vst";                                  # Устанавливаем переменную окружения для пользовательской папки VST
    VST3_PATH   = "/run/current-system/sw/lib/vst3:${myLib.home}/.vst3";                                # Устанавливаем переменную окружения для пользовательской папки VST3
    LXVST_PATH  = "/run/current-system/sw/lib/lxvst:${myLib.home}/.lxvst";                              # Устанавливаем переменную окружения для пользовательской папки LXVST (Linux VST — устаревший формат)
    LADSPA_PATH = "/run/current-system/sw/lib/ladspa:${myLib.home}/.ladspa";                            # Устанавливаем переменную окружения для пользовательской папки LADSPA (простой формат эффектов)
    DSSI_PATH   = "/run/current-system/sw/lib/dssi:${myLib.home}/.dssi";                                # Устанавливаем переменную окружения для пользовательской папки DSSI (инструменты на базе LADSPA)
  };

  services = {
    pulseaudio.enable = false;                                                                          # Отключаем старый звуковой сервер PulseAudio (полностью заменяем на PipeWire)
    pipewire = {                                                                                        # Основные настройки PipeWire
      enable = true;                                                                                    # Включаем PipeWire как основной звуковой сервер
      alsa.enable = true;                                                                               # Поддержка ALSA (эмуляция для старых приложений)
      alsa.support32Bit = true;                                                                         # Поддержка 32-битных ALSA-клиентов (для игр и старого софта)
      jack.enable = true;                                                                               # JACK-совместимость (PipeWire как JACK-сервер)
      pulse.enable = true;                                                                              # Включает pipewire-pulse — эмуляцию сервера PulseAudio поверх PipeWire
      wireplumber.enable = true;                                                                        # WirePlumber — менеджер сессий для PipeWire (более современный, чем старый media-session)
      extraConfig = {
        pipewire."99-low-latency" = {
          # ========== Основные параметры контекста PipeWire ==========
          "context.properties" = {
            "default.clock.rate" = 48000;                                                               # Частота дискретизации по умолчанию (48 кГц)
            "default.clock.quantum" = 512;                                                              # Буфер по умолчанию для приложений, которые не задают его сами (браузер, игры, плееры) — ~10,6 мс при 48 кГц
            "default.clock.min-quantum" = 64;                                                           # Минимальный буфер, который может запросить приложение (REAPER через JACK выставлен в 64) — ~1,3 мс при 48 кГц
            "default.clock.max-quantum" = 2048;                                                         # Максимальный буфер для тяжёлых приложений — ~42,7 мс, страхует от xrun
            "default.clock.allowed-rates" = [ 44100 48000 ];                                            # Разрешённые частоты дискретизации
          };
          # ========== Аргументы модуля реального времени ==========
          "module.rt.args" = {                                                                          # Переопределяем параметры уже загруженного libpipewire-module-rt
            "nice.level" = -11;                                                                         # Приоритет nice для не-RT частей (диапазон: -20..19, отрицательное = выше)
            "rt.prio" = 88;                                                                             # RT-приоритет аудио-потока (диапазон: 1..99, ограничен pam.loginLimits rtprio=89)
          };
        };
      };
    };
  };

  # ---------- Настройка приоритетов реального времени для PipeWire и WirePlumber ----------
  security = {
    rtkit.enable = true;                                                                                # Включаем rtkit (Realtime Kit) — демон, дающий процессам приоритет реального времени. Необходим для низких задержек в аудио.
    pam.loginLimits = [                                                                                 # Лимиты для аудио-группы (чтобы приложения имели приоритет реального времени и блокировку памяти)
      { domain = "@audio"; item = "rtprio"; type = "soft"; value = "89"; }                              # мягкий лимит RT-приоритета
      { domain = "@audio"; item = "rtprio"; type = "hard"; value = "89"; }                              # жёсткий лимит RT-приоритета
      { domain = "@audio"; item = "memlock"; type = "soft"; value = "unlimited"; }                      # мягкий лимит блокировки памяти
      { domain = "@audio"; item = "memlock"; type = "hard"; value = "unlimited"; }                      # жёсткий лимит блокировки памяти
      { domain = "@audio"; item = "nice"; type = "soft"; value = "-11"; }                               # разрешаем nice -11
      { domain = "@audio"; item = "nice"; type = "hard"; value = "-11"; }                               # жёсткий лимит nice
      { domain = "@audio"; item = "nofile"; type = "soft"; value = "99999"; }                           # мягкий лимит открытых файловых дескрипторов (для проектов с сотнями сэмплов и плагинов)
      { domain = "@audio"; item = "nofile"; type = "hard"; value = "99999"; }                           # жёсткий лимит открытых файловых дескрипторов
    ];
  };

  # RT-приоритеты для PipeWire (см. commonRealtime в let-блоке)
  systemd.user.services = {
    pipewire.serviceConfig = commonRealtime;
    pipewire-pulse.serviceConfig = commonRealtime;
    wireplumber.serviceConfig = commonRealtime;
  };

  systemd.tmpfiles.rules = [                                                                            # Правила tmpfiles
    # ========== Правила tmpfiles для аудио и REAPER ==========
    "d ${myLib.home}/.clap 0755 ${myLib.userName} ${myLib.userName} -"
    "d ${myLib.home}/.lv2 0755 ${myLib.userName} ${myLib.userName} -"
    "d ${myLib.home}/.vst 0755 ${myLib.userName} ${myLib.userName} -"
    "d ${myLib.home}/.vst3 0755 ${myLib.userName} ${myLib.userName} -"
    "d ${myLib.home}/.lxvst 0755 ${myLib.userName} ${myLib.userName} -"
    "d ${myLib.home}/.ladspa 0755 ${myLib.userName} ${myLib.userName} -"
    "d ${myLib.home}/.dssi 0755 ${myLib.userName} ${myLib.userName} -"
    "L+ ${myLib.home}/.local/bin/wine64 - ${myLib.userName} ${myLib.userName} - ${pkgs.wineWow64Packages.staging}/bin/wine"  # wine64
    "L+ ${myLib.home}/.config/REAPER - root root - ${myLib.home}/${myLib.configDirName}/dotfiles/config/REAPER"
    "d ${myLib.home}/.config/REAPER/UserPlugins 0755 ${myLib.userName} ${myLib.userName} -"
    "L+ ${myLib.home}/.config/REAPER/UserPlugins/reaper_sws-x86_64.so - root root - ${pkgs-unstable.reaper-sws-extension}/UserPlugins/reaper_sws-x86_64.so"  # .so файлы REAPER
    "L+ ${myLib.home}/.config/REAPER/UserPlugins/reaper_reapack-x86_64.so - root root - ${pkgs-unstable.reaper-reapack-extension}/UserPlugins/reaper_reapack-x86_64.so"  # .so файлы REAPER
    "L+ /usr/bin/zenity - - - - ${pkgs.zenity}/bin/zenity" # нужно для работы вывода меню выбора пресетов внутри плагина

    # Создаём структуру каталогов для данных Amp Locker и Drum Locker
    "d \"${myLib.home}/Audio Assault\" 0755 ${myLib.userName} ${myLib.userName} -"
    "d \"${myLib.home}/Audio Assault/PluginData\" 0755 ${myLib.userName} ${myLib.userName} -"
    "d \"${myLib.home}/Audio Assault/PluginData/Audio Assault\" 0755 ${myLib.userName} ${myLib.userName} -"
    "L+ \"${myLib.home}/Audio Assault/PluginData/Audio Assault/AmpLockerData\" - ${myLib.userName} ${myLib.userName} - /run/current-system/sw/share/amp-locker"
    "L+ \"${myLib.home}/Audio Assault/PluginData/Audio Assault/DrumLockerData\" - ${myLib.userName} ${myLib.userName} - /run/current-system/sw/share/drum-locker"

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
