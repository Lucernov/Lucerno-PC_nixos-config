{ pkgs, lib, pkgs-unstable, myLib, blender-cuda, ... }:

let
  packages = import ../packages.nix { inherit pkgs pkgs-unstable myLib blender-cuda; };                 # Импортируем общий файл с пакетами и системными модулями
  links = import ../links.nix { inherit pkgs lib myLib; };                                              # Импортируем модуль с симлинками (системные правила tmpfiles)
in

{
  system.stateVersion = myLib.channelVersion;                                                           # Версия состояния системы (соответствует каналу NixOS)
  imports = [ packages.nixosModule ];                                                                   # Подключаем модуль из packages.nix, который включает все системные опции (programs.*, environment.systemPackages)
  systemd = { tmpfiles.rules = links.systemRules; };                                                    # Правила из links.nix (мои симлинки)

  # ========== Загрузчик и ядро ==========
  boot = {
    loader = {
      systemd-boot.enable = true;                                                                       # Используем простой UEFI загрузчик systemd-boot
      efi.canTouchEfiVariables = true;                                                                  # Разрешить запись в EFI-переменные (нужно для добавления записей загрузки)
      systemd-boot.consoleMode = "auto";                                                                # детализация вывода загрузчика
    };
    supportedFilesystems = [ "exfat" ];                                                                 # Поддержка файловой системы exFAT (для флешек и внешних дисков)
    #system.nixos-init.enable = true;                                                                   # Альтернативная система инициализации (пока не используется)

    extraModprobeConfig = ''
      # Отключаем авто-отключение питания Bluetooth-адаптера (чтобы не терял связь)
      options btusb enable_autosuspend=0
      # Принудительно ограничиваем количество пакетов (стабилизирует USB-аудио)
      options snd-usb-audio nrpacks=1
      # Включаем неявный обратный канал (помогает при проблемах синхронизации)
      options snd_usb_audio implicit_fb=1
    '';
  };

  # ========== Настройки времени и локали ==========
  time = { timeZone = "Europe/Moscow"; };                                                               # Часовой пояс (Europe/Moscow)
  i18n = {
    defaultLocale = "ru_RU.UTF-8";                                                                      # Основная локаль системы – русская, кодировка UTF-8
    extraLocaleSettings = {                                                                             # Дополнительные настройки локализации для отдельных категорий
      LC_ADDRESS = "ru_RU.UTF-8";                                                                       # Формат адресов
      LC_IDENTIFICATION = "ru_RU.UTF-8";                                                                # Метаданные локали
      LC_MEASUREMENT = "ru_RU.UTF-8";                                                                   # Единицы измерения (метрическая система)
      LC_MONETARY = "ru_RU.UTF-8";                                                                      # Формат денежных единиц (рубли)
      LC_NAME = "ru_RU.UTF-8";                                                                          # Формат имён
      LC_NUMERIC = "ru_RU.UTF-8";                                                                       # Формат чисел (разделители десятичной части и тысяч)
      LC_PAPER = "ru_RU.UTF-8";                                                                         # Формат бумаги (A4)
      LC_TELEPHONE = "ru_RU.UTF-8";                                                                     # Формат телефонных номеров
      LC_TIME = "ru_RU.UTF-8";                                                                          # Формат времени (24-часовой, день.месяц.год)
    };
  };

  # ========== Пользователи и группы ==========
  users = {
    groups = {
      lucerno = {};                                                                                     # Создаём группу lucerno (явно не задаём параметры)
      powercap = {};                                                                                    # Группа для доступа к энергопотреблению CPU (RAPL) нужна для отображения в btop
      fuse = {};
      nvidia = {};
    };
    users.lucerno = {                                                                                   # Основные настройки учётной записи
      isNormalUser = true;                                                                              # Обычный пользователь (не системный)
      hashedPasswordFile = "${myLib.home}/${myLib.configDirName}/secrets/lucerno-password.hash";        # Файл с хешем пароля
      group = "lucerno";                                                                                # Группа, к которой принадлежит пользователь
      extraGroups = [ "wheel" "networkmanager" "audio" "video" "storage" "render" "powercap" "rtkit" "fuse" "nvidia" ]; # Дополнительные группы
      shell = pkgs.zsh;                                                                                 # Командная оболочка по умолчанию (Zsh)
    };
  };

  # ========== Переменные окружения ==========
  environment = {
    sessionVariables = {
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";                                                             # Принудительно указываем Vulkan-драйвер NVIDIA для OpenGL/GLX приложений
      __GL_VRR_ALLOWED = "1";                                                                           # Разрешает Variable Refresh Rate (VRR / G-Sync / FreeSync) Включает адаптивную синхронизацию для совместимых мониторов
      GBM_BACKEND = "nvidia-drm";                                                                       # Указывает бэкенд Graphics Buffer Manager (GBM) от NVIDIA. Необходимо для корректной работы Wayland с проприетарным драйвером
      CHROME_FLAGS = "--ozone-platform-hint=auto";                                                      # Флаги для браузеров на базе Chromium (Chrome, Edge, Brave и др.) Принудительно включает поддержку Wayland через Ozone
      ELECTRON_OZONE_PLATFORM_HINT = "auto";                                                            # Для приложений на Electron (VS Code, Discord, Telegram и др.) Заставляет их использовать Wayland вместо XWayland
      ELECTRON_FORCE_WAYLAND = "1";                                                                     # Принудительно запускает Electron-приложения в нативном режиме Wayland вместо XWayland
      QT_QPA_PLATFORM = "wayland";                                                                      # Задаёт бэкенд Qt для работы через Wayland (вместо X11)
      GDK_BACKEND = "wayland";                                                                          # Указывает GTK-приложениям использовать Wayland
      SDL_VIDEODRIVER = "wayland";                                                                      # Задаёт драйвер для SDL (используется в играх и мультимедиа) – Wayland
      NIXOS_OZONE_WL = "1";                                                                             # Включает поддержку Ozone Wayland для Chromium/Electron (флаг NIXOS_OZONE_WL)
      WLR_NO_HARDWARE_CURSORS = "1";                                                                    # Отключает аппаратные курсоры в wlroots (помогает избежать проблем с мерцанием курсора на NVIDIA)
      EGL_PLATFORM = "wayland";                                                                         # Указывает EGL использовать Wayland (необходимо для некоторых приложений)
      VK_ICD_FILENAMES = "/run/opengl-driver/share/vulkan/icd.d/nvidia_icd.json";                       # Указывает Vulkan Loader использовать драйвер NVIDIA вместо Mesa (например, для игр через Proton)
      VK_LAYER_DISABLE = "steam_fossilize";                                                             # Отключает слой Steam Fossilize, который иногда вызывает вылеты или тормоза в играх
      PROTON_USE_NTSYNC = "1";                                                                          # Включает улучшенную синхронизацию NTSync (вместо устаревших esync/fsync) для лучшей производительности в Proton
      PROTON_NO_ESYNC = "1";                                                                            # Отключает старую синхронизацию esync (Eventfd), так как используется NTSync
      PROTON_NO_FSYNC = "1";                                                                            # Отключает старую синхронизацию fsync (Futex), так как используется NTSync
      LIBVA_DRIVER_NAME = "nvidia";                                                                     # Указывает FFmpeg и браузерам использовать аппаратное кодирование/декодирование через NVIDIA (VA-API)
      TESSDATA_PREFIX = "/run/current-system/sw/share/tessdata";                                        # Путь к языковым данным Tesseract для OCR в Spectacle
    };
  };

  # ========== FUSE для rclone ==========
  programs = {
    fuse = {
      enable = true;                                                                                    # Включает поддержку FUSE в системе
      userAllowOther = true;                                                                            # Разрешает опцию allow_other для обычных пользователей
      mountMax = 1000;                                                                                  # Максимальное количество FUSE-монтирований на пользователя
    };
  };

  # ========== Безопасность (sudo, rtkit, лимиты) ==========
  security = {
    sudo = {
      enable = true;                                                                                    # Включаем sudo
      wheelNeedsPassword = false;                                                                       # Для членов группы wheel не требовать пароль
    };
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

  # ========== Настройки звука ==========
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

    # ========== Логи ==========
    journald.extraConfig = ''
      # максимальный общий размер постоянных логов (в /var/log/journal)
      SystemMaxUse=300M
      # максимальный размер одного файла журнала (ротация происходит при достижении этого размера)
      SystemMaxFileSize=100M
      # аналогично для временных логов (в /run/log/journal), которые хранятся до перезагрузки
      RuntimeMaxUse=300M
      # размер одного файла для runtime-логов
      RuntimeMaxFileSize=100M
      # автоматическая очистка по времени (5 дней)
      SystemMaxRetentionSec=5d
    '';

    irqbalance.enable = true;           # Включает демон irqbalance, который распределяет аппаратные прерывания между ядрами CPU.

  };

  # ========== Базовые настройки Nix ==========
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];                                               # Включаем поддержку команд Nix и флейков (flake)
      auto-optimise-store = true;                                                                       # Автоматически оптимизировать store (удалять дубликаты файлов)
      max-jobs = 6;                                                                                     # Максимальное количество параллельных сборок (задач Nix)
      keep-derivations = true;                                                                          # Сохранять деривации (промежуточные результаты сборки) – полезно для кэширования
      keep-outputs = true;                                                                              # Сохранять готовые outputs пакетов (обычно всегда true)
      substituters = [                                                                                  # Список дополнительных кэшей (substituters), откуда Nix может скачивать готовые бинарные сборки
        "https://cache.nixos.org"                                                                       # Основной кэш NixOS
        "https://cache.flox.dev"                                                                        # Официальный кэш NVIDIA/CUDA (предотвращает компиляцию CUDA из исходников)
        "https://cache.nixos-cuda.org"                                                                  # Специализированный CUDA-кэш
        "https://nix-community.cachix.org"                                                              # Кэш Nix Community
        "https://adithyagenie.cachix.org"                                                               # Кэш готовых сборок Blender с CUDA (от adithyagenie, экономит время компиляции)
        "https://chaotic-nyx.cachix.org"                                                                # Дополнительный кеш с большим количеством популярных пакетов
        "https://devenv.cachix.org"                                                                     # Кеш для сред разработки (devenv)
        "https://attic.xuyh0120.win/lantian"                                                            # Добавляем кэш аттика от xuyh0120 (содержит множество готовых сборок для CachyOS пакетов)
      ];
      trusted-public-keys = [                                                                           # Публичные ключи для проверки подписей пакетов из соответствующих кэшей
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="                                # Ключ основного кэша
        "cache.flox.dev-1:H4Tsx+8AOz3b3CvyCqVQPyEr2cHKH+O8bHn8ZgYp/po="                                 # Ключ кэша flox (CUDA)
        "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M="                             # Публичный ключ CUDA-кэша
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="                       # ключ кэша nix-community
        "adithyagenie.cachix.org-1:h6BSMboeVfxyrULWuRQqAyweo4AJRATekb88xotfQwc="                        # Публичный ключ кэша adithyagenie (Blender с CUDA)
        "chaotic-nyx.cachix.org-1:HfnXSw4pj95iI/n17rIDy40agHj12WfF+Gqk6SonIT8="                         # Ключ chaotic-nyx
        "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="                              # Ключ devenv
        "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="                                          # Публичный ключ для проверки подписей пакетов из указанного аттика.
      ];
    };
    gc = {                                                                                              # Настройки автоматической очистки старых поколений (garbage collection)
      automatic = true;                                                                                 # Включить автоматическую сборку мусора
      dates = "weekly";                                                                                 # Расписание: еженедельно (можно изменить на "daily", "monthly")
      options = "--delete-older-than 7d";                                                               # Удалять поколения старше 7 дней
    };
  };

}
