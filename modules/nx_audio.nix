{ myLib, ... }:

{
  environment.sessionVariables = {
    VST3_PATH = "${myLib.home}/.vst3";                                                                  # Устанавливаем переменную окружения для пользовательской папки VST3
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
}
