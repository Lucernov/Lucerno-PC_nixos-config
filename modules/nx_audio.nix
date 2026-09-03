{ pkgs-unstable, myLib, ... }:

let
  inherit (myLib) home;
  configDir = myLib.configDirName;
  commonRealtime = {
    CPUSchedulingPolicy = "fifo";
    CPUSchedulingPriority = 85;
    Nice = -11;
    LimitRTPRIO = 89;
    NoNewPrivileges = false;
  };
in

{
  environment.sessionVariables = {
    CLAP_PATH = "/run/current-system/sw/lib/clap:${myLib.home}/.clap";                                  # Устанавливаем переменную окружения для пользовательской папки CLAP
    LV2_PATH = "/run/current-system/sw/lib/lv2:${myLib.home}/.lv2";                                     # Устанавливаем переменную окружения для пользовательской папки LV2
    VST_PATH = "/run/current-system/sw/lib/vst:${myLib.home}/.vst";                                     # Устанавливаем переменную окружения для пользовательской папки VST
    VST3_PATH = "/run/current-system/sw/lib/vst3:${myLib.home}/.vst3";                                  # Устанавливаем переменную окружения для пользовательской папки VST3
    WINEPREFIX = "/mnt/music/MUSIC-WINE/yabridge";                                                      # Префикс Wine для Windows-плагинов, используемых через yabridge
  };

  services = {
    pulseaudio.enable = false;                                                                          # Отключаем старый звуковой сервер PulseAudio (полностью заменяем на PipeWire)
    pipewire = {                                                                                        # Основные настройки PipeWire
      enable = true;                                                                                    # Включаем PipeWire как основной звуковой сервер
      alsa.enable = true;                                                                               # Поддержка ALSA (эмуляция для старых приложений)
      alsa.support32Bit = true;                                                                         # Поддержка 32-битных ALSA-клиентов (для игр и старого софта)
      jack.enable = true;                                                                               # Эмуляция PulseAudio (чтобы приложения, ожидающие PulseAudio, работали)
      wireplumber.enable = true;                                                                        # WirePlumber — менеджер сессий для PipeWire (более современный, чем старый media-session)
      extraConfig = {                                                                                   # Дополнительная конфигурация для низкой задержки (low-latency)
        pipewire."99-low-latency" = {                                                                   # Создаём профиль с именем "99-low-latency"
          "context.properties" = {                                                                      # Основные свойства контекста PipeWire
            "default.clock.rate" = 48000;                                                               # Частота дискретизации по умолчанию (48 кГц)
            "default.clock.quantum" = 512;                                                              # Размер кванта (буфера) по умолчанию – 512 семплов (~10,6 мс при 48 кГц)
            "default.clock.min-quantum" = 64;                                                           # Минимальный размер кванта – 64 семпла (~1,3 мс при 48 кГц) – для снижения задержки
          # "default.clock.min-quantum" = 128;                                                          # Минимальный размер кванта – 128 семплов (~2,7 мс при 48 кГц) – для снижения задержки
            "default.clock.max-quantum" = 2048;                                                         # Максимальный размер кванта – 2048 семплов (~42,7 мс) – для стабильности
            "default.clock.allowed-rates" = [ 44100 48000 ];                                            # Разрешённые частоты дискретизации (44.1 и 48 кГц)
          };
          "context.modules" = [                                                                         # Загружаемые модули с параметрами реального времени
            {
              name = "libpipewire-module-rt";                                                           # Модуль для поддержки реального времени (realtime)
              args = {
                "nice.level" = -11;                                                                     # Приоритет (nice) – отрицательное значение даёт более высокий приоритет
                "rt.prio" = 85;                                                                         # Приоритет реального времени (rtprio) – 85 (требует прав через rtkit)
              };
            }
          ];
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
    ];
  };

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
    "L+ ${myLib.home}/.local/bin/wine64 - ${myLib.userName} ${myLib.userName} - ${pkgs-unstable.wineWow64Packages.staging}/bin/wine"  # wine64
    "L+ ${myLib.home}/.config/REAPER/UserPlugins/reaper_sws-x86_64.so - ${myLib.userName} ${myLib.userName} - ${pkgs-unstable.reaper-sws-extension}/UserPlugins/reaper_sws-x86_64.so"  # .so файлы REAPER
    "L+ ${myLib.home}/.config/REAPER/UserPlugins/reaper_reapack-x86_64.so - ${myLib.userName} ${myLib.userName} - ${pkgs-unstable.reaper-reapack-extension}/UserPlugins/reaper_reapack-x86_64.so"  # .so файлы REAPER
    "L+ /usr/bin/zenity - - - - /run/current-system/sw/bin/zenity" # нужно для работы вывода меню выбора пресетов внутри плагина
    #"L+ /usr/bin/kdialog - - - - /run/current-system/sw/bin/kdialog" # нужно для работы вывода меню выбора пресетов внутри плагина

    # ---------- Симлинки для CLAP-плагинов ----------
    "L+ \"${myLib.home}/.clap/DragonflyEarlyReflections.clap\" - ${myLib.userName} ${myLib.userName} - /run/current-system/sw/lib/clap/DragonflyEarlyReflections.clap"
    "L+ \"${myLib.home}/.clap/DragonflyHallReverb.clap\" - ${myLib.userName} ${myLib.userName} - /run/current-system/sw/lib/clap/DragonflyHallReverb.clap"
    "L+ \"${myLib.home}/.clap/DragonflyPlateReverb.clap\" - ${myLib.userName} ${myLib.userName} - /run/current-system/sw/lib/clap/DragonflyPlateReverb.clap"
    "L+ \"${myLib.home}/.clap/DragonflyRoomReverb.clap\" - ${myLib.userName} ${myLib.userName} - /run/current-system/sw/lib/clap/DragonflyRoomReverb.clap"
    "L+ ${myLib.home}/.clap/lsp-plugins.clap - ${myLib.userName} ${myLib.userName} - /run/current-system/sw/lib/clap/lsp-plugins.clap"
    "L+ ${myLib.home}/.clap/OsTIrus.clap - ${myLib.userName} ${myLib.userName} - /run/current-system/sw/lib/clap/OsTIrus.clap"
    "L+ ${myLib.home}/.clap/Ratatouille.clap - ${myLib.userName} ${myLib.userName} - /run/current-system/sw/lib/clap/Ratatouille.clap"
    "L+ ${myLib.home}/.clap/sforzando.clap - ${myLib.userName} ${myLib.userName} - /run/current-system/sw/lib/clap/sforzando.clap"
    "L+ \"${myLib.home}/.clap/Shortcircuit XT.clap\" - ${myLib.userName} ${myLib.userName} - /run/current-system/sw/lib/clap/Shortcircuit XT.clap"
    "L+ \"${myLib.home}/.clap/Surge XT Effects.clap\" - ${myLib.userName} ${myLib.userName} - /run/current-system/sw/lib/clap/Surge XT Effects.clap"
    "L+ \"${myLib.home}/.clap/Surge XT.clap\" - ${myLib.userName} ${myLib.userName} - /run/current-system/sw/lib/clap/Surge XT.clap"
    "L+ ${myLib.home}/.clap/Vital.clap - ${myLib.userName} ${myLib.userName} - /run/current-system/sw/lib/clap/Vital.clap"
    # ---------- Симлинки для LV2-плагинов ----------
    "L+ \"${myLib.home}/.lv2/Amp Locker.lv2\" - ${myLib.userName} ${myLib.userName} - /run/current-system/sw/lib/lv2/Amp Locker.lv2"
    "L+ ${myLib.home}/.lv2/calf.lv2 - ${myLib.userName} ${myLib.userName} - /run/current-system/sw/lib/lv2/calf.lv2"
    "L+ \"${myLib.home}/.lv2/DragonflyEarlyReflections.lv2\" - ${myLib.userName} ${myLib.userName} - /run/current-system/sw/lib/lv2/DragonflyEarlyReflections.lv2"
    "L+ \"${myLib.home}/.lv2/DragonflyHallReverb.lv2\" - ${myLib.userName} ${myLib.userName} - /run/current-system/sw/lib/lv2/DragonflyHallReverb.lv2"
    "L+ \"${myLib.home}/.lv2/DragonflyPlateReverb.lv2\" - ${myLib.userName} ${myLib.userName} - /run/current-system/sw/lib/lv2/DragonflyPlateReverb.lv2"
    "L+ \"${myLib.home}/.lv2/DragonflyRoomReverb.lv2\" - ${myLib.userName} ${myLib.userName} - /run/current-system/sw/lib/lv2/DragonflyRoomReverb.lv2"
    "L+ \"${myLib.home}/.lv2/Drum Locker.lv2\" - ${myLib.userName} ${myLib.userName} - /run/current-system/sw/lib/lv2/Drum Locker.lv2"
    "L+ ${myLib.home}/.lv2/drumgizmo.lv2 - ${myLib.userName} ${myLib.userName} - /run/current-system/sw/lib/lv2/drumgizmo.lv2"
    "L+ ${myLib.home}/.lv2/drumlabooh-multi.lv2 - ${myLib.userName} ${myLib.userName} - /run/current-system/sw/lib/lv2/drumlabooh-multi.lv2"
    "L+ ${myLib.home}/.lv2/drumlabooh.lv2 - ${myLib.userName} ${myLib.userName} - /run/current-system/sw/lib/lv2/drumlabooh.lv2"
    "L+ ${myLib.home}/.lv2/geonkick.lv2 - ${myLib.userName} ${myLib.userName} - /run/current-system/sw/lib/lv2/geonkick.lv2"
    "L+ ${myLib.home}/.lv2/lsp-plugins.lv2 - ${myLib.userName} ${myLib.userName} - /run/current-system/sw/lib/lv2/lsp-plugins.lv2"
    "L+ ${myLib.home}/.lv2/Ratatouille.lv2 - ${myLib.userName} ${myLib.userName} - /run/current-system/sw/lib/lv2/Ratatouille.lv2"
    "L+ \"${myLib.home}/.lv2/Surge XT Effects.lv2\" - ${myLib.userName} ${myLib.userName} - /run/current-system/sw/lib/lv2/Surge XT Effects.lv2"
    "L+ \"${myLib.home}/.lv2/Surge XT.lv2\" - ${myLib.userName} ${myLib.userName} - /run/current-system/sw/lib/lv2/Surge XT.lv2"
    # ---------- Симлинки для VST2-плагинов ----------
    "L+ ${myLib.home}/.vst/DecentSampler.so - ${myLib.userName} ${myLib.userName} - /run/current-system/sw/lib/vst/DecentSampler.so"
    "L+ ${myLib.home}/.vst/lsp-plugins.vst - ${myLib.userName} ${myLib.userName} - /run/current-system/sw/lib/vst/lsp-plugins.vst"
    "L+ ${myLib.home}/.vst/OT_P1ANO_S.so - ${myLib.userName} ${myLib.userName} - /run/current-system/sw/lib/vst/OT_P1ANO_S.so"
    "L+ ${myLib.home}/.vst/Ratatouillevst.so - ${myLib.userName} ${myLib.userName} - /run/current-system/sw/lib/vst/Ratatouillevst.so"
    "L+ ${myLib.home}/.vst/Vital.so - ${myLib.userName} ${myLib.userName} - /run/current-system/sw/lib/vst/Vital.so"
    # ---------- Симлинки для VST3-плагинов ----------
    "L+ \"${myLib.home}/.vst3/Amp Locker.vst3\" - ${myLib.userName} ${myLib.userName} - /run/current-system/sw/lib/vst3/Amp Locker.vst3"
    "L+ \"${myLib.home}/.vst3/DecentSampler.vst3\" - ${myLib.userName} ${myLib.userName} - /run/current-system/sw/lib/vst3/DecentSampler.vst3"
    "L+ \"${myLib.home}/.vst3/DragonflyEarlyReflections.vst3\" - ${myLib.userName} ${myLib.userName} - /run/current-system/sw/lib/vst3/DragonflyEarlyReflections.vst3"
    "L+ \"${myLib.home}/.vst3/DragonflyHallReverb.vst3\" - ${myLib.userName} ${myLib.userName} - /run/current-system/sw/lib/vst3/DragonflyHallReverb.vst3"
    "L+ \"${myLib.home}/.vst3/DragonflyPlateReverb.vst3\" - ${myLib.userName} ${myLib.userName} - /run/current-system/sw/lib/vst3/DragonflyPlateReverb.vst3"
    "L+ \"${myLib.home}/.vst3/DragonflyRoomReverb.vst3\" - ${myLib.userName} ${myLib.userName} - /run/current-system/sw/lib/vst3/DragonflyRoomReverb.vst3"
    "L+ \"${myLib.home}/.vst3/Drum Locker.vst3\" - ${myLib.userName} ${myLib.userName} - /run/current-system/sw/lib/vst3/Drum Locker.vst3"
    "L+ ${myLib.home}/.vst3/lsp-plugins.vst3 - ${myLib.userName} ${myLib.userName} - /run/current-system/sw/lib/vst3/lsp-plugins.vst3"
    "L+ ${myLib.home}/.vst3/MT-PowerDrumKit.vst3 - ${myLib.userName} ${myLib.userName} - /run/current-system/sw/lib/vst3/MT-PowerDrumKit.vst3"
    "L+ \"${myLib.home}/.vst3/OT BRASS.vst3\" - ${myLib.userName} ${myLib.userName} - /run/current-system/sw/lib/vst3/OT BRASS.vst3"
    "L+ \"${myLib.home}/.vst3/OT PERC.vst3\" - ${myLib.userName} ${myLib.userName} - /run/current-system/sw/lib/vst3/OT PERC.vst3"
    "L+ \"${myLib.home}/.vst3/OT STRINGS.vst3\" - ${myLib.userName} ${myLib.userName} - /run/current-system/sw/lib/vst3/OT STRINGS.vst3"
    "L+ \"${myLib.home}/.vst3/OT WINDS.vst3\" - ${myLib.userName} ${myLib.userName} - /run/current-system/sw/lib/vst3/OT WINDS.vst3"
    "L+ \"${myLib.home}/.vst3/sforzando.vst3\" - ${myLib.userName} ${myLib.userName} - /run/current-system/sw/lib/vst3/sforzando.vst3"
    "L+ \"${myLib.home}/.vst3/Surge XT Effects.vst3\" - ${myLib.userName} ${myLib.userName} - /run/current-system/sw/lib/vst3/Surge XT Effects.vst3"
    "L+ \"${myLib.home}/.vst3/Surge XT.vst3\" - ${myLib.userName} ${myLib.userName} - /run/current-system/sw/lib/vst3/Surge XT.vst3"
    "L+ ${myLib.home}/.vst3/Vital.vst3 - ${myLib.userName} ${myLib.userName} - /run/current-system/sw/lib/vst3/Vital.vst3"
    # Air-G Plugins
    "L+ \"${myLib.home}/.vst3/AirGClip.vst3\" - ${myLib.userName} ${myLib.userName} - /run/current-system/sw/lib/vst3/AirGClip.vst3"
    "L+ \"${myLib.home}/.vst3/AirGDess.vst3\" - ${myLib.userName} ${myLib.userName} - /run/current-system/sw/lib/vst3/AirGDess.vst3"
    "L+ \"${myLib.home}/.vst3/AirGEaseq.vst3\" - ${myLib.userName} ${myLib.userName} - /run/current-system/sw/lib/vst3/AirGEaseq.vst3"
    "L+ \"${myLib.home}/.vst3/AirGEchoes.vst3\" - ${myLib.userName} ${myLib.userName} - /run/current-system/sw/lib/vst3/AirGEchoes.vst3"
    "L+ \"${myLib.home}/.vst3/AirGMods.vst3\" - ${myLib.userName} ${myLib.userName} - /run/current-system/sw/lib/vst3/AirGMods.vst3"
    "L+ \"${myLib.home}/.vst3/AirGPop.vst3\" - ${myLib.userName} ${myLib.userName} - /run/current-system/sw/lib/vst3/AirGPop.vst3"
    "L+ \"${myLib.home}/.vst3/AirGPopMini.vst3\" - ${myLib.userName} ${myLib.userName} - /run/current-system/sw/lib/vst3/AirGPopMini.vst3"
    "L+ \"${myLib.home}/.vst3/AirGPrism.vst3\" - ${myLib.userName} ${myLib.userName} - /run/current-system/sw/lib/vst3/AirGPrism.vst3"
    "L+ \"${myLib.home}/.vst3/AirGPulse.vst3\" - ${myLib.userName} ${myLib.userName} - /run/current-system/sw/lib/vst3/AirGPulse.vst3"
    "L+ \"${myLib.home}/.vst3/AirGPulseMini.vst3\" - ${myLib.userName} ${myLib.userName} - /run/current-system/sw/lib/vst3/AirGPulseMini.vst3"
    "L+ \"${myLib.home}/.vst3/AirGSpaces.vst3\" - ${myLib.userName} ${myLib.userName} - /run/current-system/sw/lib/vst3/AirGSpaces.vst3"
    "L+ \"${myLib.home}/.vst3/AirGTape.vst3\" - ${myLib.userName} ${myLib.userName} - /run/current-system/sw/lib/vst3/AirGTape.vst3"
    "L+ \"${myLib.home}/.vst3/AirGTaped.vst3\" - ${myLib.userName} ${myLib.userName} - /run/current-system/sw/lib/vst3/AirGTaped.vst3"
    "L+ \"${myLib.home}/.vst3/AirGTapedMini.vst3\" - ${myLib.userName} ${myLib.userName} - /run/current-system/sw/lib/vst3/AirGTapedMini.vst3"
    "L+ \"${myLib.home}/.vst3/AirGVelvet.vst3\" - ${myLib.userName} ${myLib.userName} - /run/current-system/sw/lib/vst3/AirGVelvet.vst3"
    "L+ \"${myLib.home}/.vst3/AirGVelvetMini.vst3\" - ${myLib.userName} ${myLib.userName} - /run/current-system/sw/lib/vst3/AirGVelvetMini.vst3"
    "L+ \"${myLib.home}/.vst3/AirGVolt.vst3\" - ${myLib.userName} ${myLib.userName} - /run/current-system/sw/lib/vst3/AirGVolt.vst3"
    "L+ \"${myLib.home}/.vst3/AirGVoltMini.vst3\" - ${myLib.userName} ${myLib.userName} - /run/current-system/sw/lib/vst3/AirGVoltMini.vst3"

    # Создаём структуру каталогов для данных Amp Locker и Drum Locker
    "d \"${myLib.home}/Audio Assault\" 0755 ${myLib.userName} ${myLib.userName} -"
    "d \"${myLib.home}/Audio Assault/PluginData\" 0755 ${myLib.userName} ${myLib.userName} -"
    "d \"${myLib.home}/Audio Assault/PluginData/Audio Assault\" 0755 ${myLib.userName} ${myLib.userName} -"
    "L+ \"${myLib.home}/Audio Assault/PluginData/Audio Assault/AmpLockerData\" - ${myLib.userName} ${myLib.userName} - /run/current-system/sw/share/amp-locker"
    "L+ \"${myLib.home}/Audio Assault/PluginData/Audio Assault/DrumLockerData\" - ${myLib.userName} ${myLib.userName} - /run/current-system/sw/share/drum-locker"

    # ---------- Симлинки конфигов плагинов ----------
    "d ${myLib.home}/.config/REAPER/UserPlugins 0755 ${myLib.userName} ${myLib.userName} -"
    "L+ ${home}/.config/REAPER - ${myLib.userName} ${myLib.userName} - ${home}/${configDir}/dotfiles/config/REAPER"
    "L+ ${home}/.config/yabridgectl - ${myLib.userName} ${myLib.userName} - ${home}/${configDir}/dotfiles/config/yabridgectl"
    "L+ ${home}/.config/DecentSampler - ${myLib.userName} ${myLib.userName} - /mnt/sys_archiv/samples/DecentSampler"
    "L+ \"${myLib.home}/.config/Amp Locker\" - ${myLib.userName} ${myLib.userName} - ${myLib.home}/${configDir}/dotfiles/config/plugins/config_Amp Locker"
    "L+ \"${myLib.home}/.config/Audio Assault\" - ${myLib.userName} ${myLib.userName} - ${myLib.home}/${configDir}/dotfiles/config/plugins/config_Audio Assault"
    "L+ ${myLib.home}/.config/geonkick - ${myLib.userName} ${myLib.userName} - ${myLib.home}/${configDir}/dotfiles/config/plugins/config_geonkick"
    "L+ ${myLib.home}/.config/lsp-plugins - ${myLib.userName} ${myLib.userName} - ${myLib.home}/${configDir}/dotfiles/config/plugins/config_lsp-plugins"
    "L+ ${myLib.home}/.config/3VStudio - ${myLib.userName} ${myLib.userName} - ${myLib.home}/${configDir}/dotfiles/config/plugins/config_3VStudio"
    "L+ \"${myLib.home}/.config/My Company\" - ${myLib.userName} ${myLib.userName} - ${myLib.home}/${configDir}/dotfiles/config/plugins/config_My Company"
    "L+ ${myLib.home}/.config/MANDA_AUDIO - ${myLib.userName} ${myLib.userName} - ${myLib.home}/${configDir}/dotfiles/config/plugins/config_MANDA_AUDIO"
    "L+ ${myLib.home}/.local/share/geonkick - ${myLib.userName} ${myLib.userName} - ${myLib.home}/${configDir}/dotfiles/config/plugins/local_share_geonkick"
    "L+ \"${myLib.home}/.local/share/The Usual Suspects\" - ${myLib.userName} ${myLib.userName} - ${myLib.home}/${configDir}/dotfiles/config/plugins/local_share_The Usual Suspects"
    "L+ ${home}/.local/share/vital - ${myLib.userName} ${myLib.userName} - /mnt/sys_archiv/samples/vital"
    "L+ ${home}/drum_sklad - ${myLib.userName} ${myLib.userName} - /mnt/sys_archiv/samples/drum_sklad"
  ];
}
