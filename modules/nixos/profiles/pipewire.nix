{ ... }:

{
  # ========== Настройки звука (PipeWire) ==========
  services.pulseaudio.enable = false;                       # Отключаем старый звуковой сервер PulseAudio (полностью заменяем на PipeWire)
  security.rtkit.enable = true;                             # Включаем rtkit (Realtime Kit) — демон, дающий процессам приоритет реального времени. Необходим для низких задержек в аудио.

  services.pipewire = {                                     # Основные настройки PipeWire
    enable = true;                                          # Включаем PipeWire как основной звуковой сервер
    alsa.enable = true;                                     # Поддержка ALSA (эмуляция для старых приложений)
    alsa.support32Bit = true;                               # Поддержка 32-битных ALSA-клиентов (для игр и старого софта)
    jack.enable = true;                                     # Поддержка JACK (для профессиональных аудио-приложений)
    pulse.enable = true;                                    # Эмуляция PulseAudio (чтобы приложения, ожидающие PulseAudio, работали)
    wireplumber.enable = true;                              # WirePlumber — менеджер сессий для PipeWire (более современный, чем старый media-session)
    extraConfig = {                                         # Дополнительная конфигурация для низкой задержки (low-latency)
      pipewire."99-low-latency" = {                         # Создаём профиль с именем "99-low-latency"
        "context.properties" = {                            # Основные свойства контекста PipeWire
          "default.clock.rate" = 48000;                     # Частота дискретизации по умолчанию (48 кГц)
          "default.clock.quantum" = 512;                    # Размер кванта (буфера) по умолчанию – 512 семплов (~10,6 мс при 48 кГц)
          "default.clock.min-quantum" = 256;                # Минимальный размер кванта – 256 семплов (~5,3 мс) – для снижения задержки
          "default.clock.max-quantum" = 2048;               # Максимальный размер кванта – 2048 семплов (~42,7 мс) – для стабильности
          "default.clock.allowed-rates" = [ 44100 48000 ];  # Разрешённые частоты дискретизации (44.1 и 48 кГц)
        };
        "context.modules" = [                               # Загружаемые модули с параметрами реального времени
          {
            name = "libpipewire-module-rt";
            args = {
              "nice.level" = -15;                           # Приоритет (nice) – отрицательное значение даёт более высокий приоритет
              "rt.prio" = 88;                               # Приоритет реального времени (rtprio) – 88 (требует прав через rtkit)
            };
          }
        ];
      };
    };
  };
}
