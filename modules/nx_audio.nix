{ pkgs, pkgs-unstable, myLib, ... }:

let
  inherit (myLib) home;
  configDir = myLib.configDirName;
in

{
  environment.sessionVariables = {
    CLAP_PATH = "/run/current-system/sw/lib/clap:${myLib.home}/.clap";                                  # Устанавливаем переменную окружения для пользовательской папки CLAP
    LV2_PATH = "/run/current-system/sw/lib/lv2:${myLib.home}/.lv2";                                     # Устанавливаем переменную окружения для пользовательской папки LV2
    VST3_PATH = "/run/current-system/sw/lib/vst3:${myLib.home}/.vst3";                                  # Устанавливаем переменную окружения для пользовательской папки VST3
    WINEPREFIX = "/mnt/music/wine-yabridge";                                                            # Префикс Wine для Windows-плагинов, используемых через yabridge
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
            "default.clock.min-quantum" = 128;                                                          # Минимальный размер кванта – 128 семплов (~2,7 мс при 48 кГц) – для снижения задержки
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

  # ========== Настройки реального времени для аудио ==========
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

  # ========== Правила tmpfiles для аудио и REAPER ==========
  systemd.tmpfiles.rules = [
    "d ${myLib.home}/.clap 0755 lucerno lucerno -"
    "d ${myLib.home}/.lv2 0755 lucerno lucerno -"
    "d ${myLib.home}/.vst3 0755 lucerno lucerno -"
    "L+ ${myLib.home}/.local/bin/wine64 - lucerno lucerno - ${pkgs-unstable.wineWow64Packages.staging}/bin/wine"  # wine64
    "L+ ${myLib.home}/.config/REAPER/UserPlugins/reaper_sws-x86_64.so - lucerno lucerno - ${pkgs-unstable.reaper-sws-extension}/UserPlugins/reaper_sws-x86_64.so"  # .so файлы REAPER
    "L+ ${myLib.home}/.config/REAPER/UserPlugins/reaper_reapack-x86_64.so - lucerno lucerno - ${pkgs-unstable.reaper-reapack-extension}/UserPlugins/reaper_reapack-x86_64.so"  # .so файлы REAPER

    "L+ ${myLib.home}/.clap/OsTIrus.clap - lucerno lucerno - /run/current-system/sw/lib/clap/OsTIrus.clap"
    "L+ ${myLib.home}/.lv2/drumlabooh.lv2 - lucerno lucerno - /run/current-system/sw/lib/lv2/drumlabooh.lv2"
    "L+ ${myLib.home}/.lv2/drumlabooh-multi.lv2 - lucerno lucerno - /run/current-system/sw/lib/lv2/drumlabooh-multi.lv2"
    "L+ ${myLib.home}/.vst3/MT-PowerDrumKit.vst3 - lucerno lucerno - /run/current-system/sw/lib/vst3/MT-PowerDrumKit.vst3"

    # Создаём структуру каталогов для данных Amp Locker и Drum Locker
    "d \"${myLib.home}/Audio Assault\" 0755 lucerno lucerno -"
    "d \"${myLib.home}/Audio Assault/PluginData\" 0755 lucerno lucerno -"
    "d \"${myLib.home}/Audio Assault/PluginData/Audio Assault\" 0755 lucerno lucerno -"
    "L+ \"${myLib.home}/Audio Assault/PluginData/Audio Assault/AmpLockerData\" - lucerno lucerno - /run/current-system/sw/share/amp-locker"
    "L+ \"${myLib.home}/Audio Assault/PluginData/Audio Assault/DrumLockerData\" - lucerno lucerno - /run/current-system/sw/share/drum-locker"

    # ---------- Симлинки конфигов плагинов ----------
    "d ${myLib.home}/.config/REAPER/UserPlugins 0755 lucerno lucerno -"
    "L+ ${home}/.config/REAPER - lucerno lucerno - ${home}/${configDir}/dotfiles/config/REAPER"
    "L+ ${home}/.config/yabridgectl - lucerno lucerno - ${home}/${configDir}/dotfiles/config/yabridgectl"
    "L+ ${home}/.config/DecentSampler - lucerno lucerno - /mnt/sys_archiv/samples/DecentSampler"
    "L+ \"${myLib.home}/.config/Amp Locker\" - lucerno lucerno - ${myLib.home}/${configDir}/dotfiles/config/plugins/config_Amp Locker"
    "L+ \"${myLib.home}/.config/Audio Assault\" - lucerno lucerno - ${myLib.home}/${configDir}/dotfiles/config/plugins/config_Audio Assault"
    "L+ ${myLib.home}/.config/geonkick - lucerno lucerno - ${myLib.home}/${configDir}/dotfiles/config/plugins/config_geonkick"
    "L+ ${myLib.home}/.config/lsp-plugins - lucerno lucerno - ${myLib.home}/${configDir}/dotfiles/config/plugins/config_lsp-plugins"
    "L+ ${myLib.home}/.config/3VStudio - lucerno lucerno - ${myLib.home}/${configDir}/dotfiles/config/plugins/config_3VStudio"
    "L+ ${myLib.home}/.config/MANDA_AUDIO - lucerno lucerno - ${myLib.home}/${configDir}/dotfiles/config/plugins/config_MANDA_AUDIO"
    "L+ ${myLib.home}/.local/share/geonkick - lucerno lucerno - ${myLib.home}/${configDir}/dotfiles/config/plugins/local_share_geonkick"
    "L+ \"${myLib.home}/.local/share/The Usual Suspects\" - lucerno lucerno - ${myLib.home}/${configDir}/dotfiles/config/plugins/local_share_The Usual Suspects"
    "L+ ${home}/.local/share/vital - lucerno lucerno - /mnt/sys_archiv/samples/vital"
    "L+ ${home}/drum_sklad - lucerno lucerno - /mnt/sys_archiv/samples/drum_sklad"

    # ---------- Каталоги для drop‑in файлов systemd --user ----------
    "d ${myLib.home}/.config/systemd 0755 lucerno lucerno -"
    "d ${myLib.home}/.config/systemd/user 0755 lucerno lucerno -"
    "d ${myLib.home}/.config/systemd/user/pipewire.service.d 0755 lucerno lucerno -"
    "d ${myLib.home}/.config/systemd/user/pipewire-pulse.service.d 0755 lucerno lucerno -"
    "d ${myLib.home}/.config/systemd/user/wireplumber.service.d 0755 lucerno lucerno -"

    # ---------- Настройка приоритетов реального времени для PipeWire и WirePlumber ----------
    "f ${myLib.home}/.config/systemd/user/pipewire.service.d/99-realtime.conf 0644 lucerno lucerno - ${pkgs.writeText "99-realtime.conf" ''
    [Service]
    CPUSchedulingPolicy=fifo
    CPUSchedulingPriority=85
    Nice=-11
    LimitRTPRIO=89
    ''}"

    "f ${myLib.home}/.config/systemd/user/pipewire-pulse.service.d/99-realtime.conf 0644 lucerno lucerno - ${pkgs.writeText "99-realtime.conf" ''
    [Service]
    CPUSchedulingPolicy=fifo
    CPUSchedulingPriority=85
    Nice=-11
    LimitRTPRIO=89
    ''}"

    "f ${myLib.home}/.config/systemd/user/wireplumber.service.d/99-realtime.conf 0644 lucerno lucerno - ${pkgs.writeText "99-realtime.conf" ''
    [Service]
    CPUSchedulingPolicy=fifo
    CPUSchedulingPriority=85
    Nice=-11
    LimitRTPRIO=89
    ''}"
  ];
}
