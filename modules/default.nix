# modules/default.nix
{ config, pkgs, lib, pkgs-unstable, inputs, myLib, ... }:

{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  system.stateVersion = myLib.channelVersion;

  imports = [
    ../hardware-configuration.nix
    ./nx_soft.nix
    ./nx_stylix.nix
    ./nx_configuration-kde_plasma.nix
    ./nx_samba.nix
    ./nx_comfyui.nix
  ];


  # ========== мои симлинки ==========
  systemd.tmpfiles.rules = [
    "d /mnt/www-GoogleDrive 0755 lucerno users -"
    "d /mnt/www-OneDrive 0755 lucerno users -"
    "d /home/lucerno/.local/share 0755 lucerno lucerno -"
    "d /home/lucerno/.config 0755 lucerno lucerno -"
    "d /home/lucerno/${myLib.configDirName}/secrets 0750 lucerno lucerno -"
    "L+ /home/lucerno/drum_sklad - - - - /mnt/sys_archiv/samples/drum_sklad"
    "L+ /home/lucerno/.local/share/Steam/userdata - - - - /home/lucerno/${myLib.configDirName}/dotfiles/config/Steam/userdata"
    "L+ /home/lucerno/.local/share/vital - - - - /mnt/sys_archiv/samples/vital"
    "L+ /home/lucerno/.config/comfy-ui - - - - /mnt/ai/ComfyUI"
    "L+ /home/lucerno/.config/rclone - - - - /home/lucerno/${myLib.configDirName}/dotfiles/config/rclone"
    "L+ /home/lucerno/.config/btop - - - - /home/lucerno/${myLib.configDirName}/dotfiles/config/btop"
    "L+ /home/lucerno/.config/AmneziaVPN.ORG - - - - /home/lucerno/${myLib.configDirName}/dotfiles/config/AmneziaVPN.ORG"
    "L+ /home/lucerno/.config/obs-studio - - - - /home/lucerno/${myLib.configDirName}/dotfiles/config/obs-studio"
    "L+ /home/lucerno/.config/DecentSampler - - - - /mnt/sys_archiv/samples/DecentSampler"
    "L+ /home/lucerno/.config/REAPER - - - - /home/lucerno/${myLib.configDirName}/dotfiles/config/REAPER"
    "L+ /home/lucerno/.config/yabridgectl - - - - /home/lucerno/${myLib.configDirName}/dotfiles/config/yabridgectl"
    "L+ /home/lucerno/.config/MangoHud - - - - /home/lucerno/${myLib.configDirName}/dotfiles/config/MangoHud"
    "L+ /home/lucerno/.local/share/Steam/steamapps - - - - /mnt/games/SteamLibrary/steamapps"

    "L+ /home/lucerno/.config/kglobalshortcutsrc - - - - /home/lucerno/${myLib.configDirName}/dotfiles/config/KDE/config-kglobalshortcutsrc"
    "L+ /home/lucerno/.local/share/applications/net.local.kitten - - - - /home/lucerno/${myLib.configDirName}/dotfiles/config/KDE/local-share-applications-net.local.kitten"
  ];


  # ========== Загрузчик ==========
  boot.loader = {
    systemd-boot.enable = true;                                                                 # Используем systemd-boot (простой UEFI загрузчик)
    efi.canTouchEfiVariables = true;                                                            # Разрешить запись в EFI-переменные (нужно для добавления записей загрузки)
    systemd-boot.consoleMode = "auto";                                                          # детализация вывода загрузчика
  };
  boot.supportedFilesystems = [ "exfat" ];                                                      # Поддержка файловой системы exFAT (для флешек и внешних дисков)
  #system.nixos-init.enable = true;                                                             # Альтернативная система инициализации (пока не используется)

  boot.extraModprobeConfig = ''
    # Отключаем авто-отключение питания Bluetooth-адаптера (чтобы не терял связь)
    options btusb enable_autosuspend=0
  '';


  # ========== Настройки времени и локали ==========
  time.timeZone = "Europe/Moscow";                                                              # Часовой пояс (Europe/Moscow)
  i18n.defaultLocale = "ru_RU.UTF-8";                                                           # Основная локаль системы – русская, кодировка UTF-8
  i18n.extraLocaleSettings = {                                                                  # Дополнительные настройки локализации для отдельных категорий
    LC_ADDRESS = "ru_RU.UTF-8";                                                                 # Формат адресов
    LC_IDENTIFICATION = "ru_RU.UTF-8";                                                          # Метаданные локали
    LC_MEASUREMENT = "ru_RU.UTF-8";                                                             # Единицы измерения (метрическая система)
    LC_MONETARY = "ru_RU.UTF-8";                                                                # Формат денежных единиц (рубли)
    LC_NAME = "ru_RU.UTF-8";                                                                    # Формат имён
    LC_NUMERIC = "ru_RU.UTF-8";                                                                 # Формат чисел (разделители десятичной части и тысяч)
    LC_PAPER = "ru_RU.UTF-8";                                                                   # Формат бумаги (A4)
    LC_TELEPHONE = "ru_RU.UTF-8";                                                               # Формат телефонных номеров
    LC_TIME = "ru_RU.UTF-8";                                                                    # Формат времени (24-часовой, день.месяц.год)
  };


  # ========== Настройка пользователя lucerno ==========
  users.groups.lucerno = {};                                                                    # Создаём группу lucerno (явно не задаём параметры)
  users.groups.powercap = {};                                                                   # Группа для доступа к энергопотреблению CPU (RAPL) нужна для отображения в btop
  users.users.lucerno = {                                                                       # Основные настройки учётной записи
    isNormalUser = true;                                                                        # Обычный пользователь (не системный)
    hashedPasswordFile = "/home/lucerno/${myLib.configDirName}/secrets/lucerno-password.hash";  # Файл с хешем пароля
    group = "lucerno";                                                                          # Группа, к которой принадлежит пользователь
    extraGroups = [ "wheel" "networkmanager" "audio" "video" "storage" "render" "powercap" ];   # Дополнительные группы
    shell = pkgs.zsh;                                                                           # Командная оболочка по умолчанию (Zsh)
  };
  # ========== Настройка sudo ==========
  security.sudo = {
    enable = true;                                                                              # Включаем sudo
    wheelNeedsPassword = false;                                                                 # Для членов группы wheel не требовать пароль
  };


  # ========== Переменные окружения для Wayland и NVIDIA ==========
  environment.sessionVariables = {
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";                                                       # Принудительно указываем Vulkan-драйвер NVIDIA для OpenGL/GLX приложений
    __GL_VRR_ALLOWED = "1";                                                                     # Разрешает Variable Refresh Rate (VRR / G-Sync / FreeSync) Включает адаптивную синхронизацию для совместимых мониторов
    GBM_BACKEND = "nvidia-drm";                                                                 # Указывает бэкенд Graphics Buffer Manager (GBM) от NVIDIA. Необходимо для корректной работы Wayland с проприетарным драйвером
    CHROME_FLAGS = "--ozone-platform-hint=auto";                                                # Флаги для браузеров на базе Chromium (Chrome, Edge, Brave и др.) Принудительно включает поддержку Wayland через Ozone
    ELECTRON_OZONE_PLATFORM_HINT = "auto";                                                      # Для приложений на Electron (VS Code, Discord, Telegram и др.) Заставляет их использовать Wayland вместо XWayland
    ELECTRON_FORCE_WAYLAND = "1";                                                               # Принудительно запускает Electron-приложения в нативном режиме Wayland вместо XWayland
    QT_QPA_PLATFORM = "wayland";                                                                # Задаёт бэкенд Qt для работы через Wayland (вместо X11)
    QT_QPA_PLATFORM_PLUGIN_PATH = "${pkgs.qt6.qtwayland}/lib/qt-6/plugins/platforms";           # Путь к плагинам Qt для поддержки Wayland. Без этого некоторые Qt-приложения могут не запускаться под Wayland
    GDK_BACKEND = "wayland";                                                                    # Указывает GTK-приложениям использовать Wayland
    SDL_VIDEODRIVER = "wayland";                                                                # Задаёт драйвер для SDL (используется в играх и мультимедиа) – Wayland
    NIXOS_OZONE_WL = "1";                                                                       # Включает поддержку Ozone Wayland для Chromium/Electron (флаг NIXOS_OZONE_WL)
    WLR_NO_HARDWARE_CURSORS = "1";                                                              # Отключает аппаратные курсоры в wlroots (помогает избежать проблем с мерцанием курсора на NVIDIA)
    EGL_PLATFORM = "wayland";                                                                   # Указывает EGL использовать Wayland (необходимо для некоторых приложений)
    VK_ICD_FILENAMES = "/run/opengl-driver/share/vulkan/icd.d/nvidia_icd.json";                 # Указывает Vulkan Loader использовать драйвер NVIDIA вместо Mesa (например, для игр через Proton)
    VK_LAYER_DISABLE = "steam_fossilize";                                                       # Отключает слой Steam Fossilize, который иногда вызывает вылеты или тормоза в играх
    PROTON_USE_NTSYNC = "1";                                                                    # Включает улучшенную синхронизацию NTSync (вместо устаревших esync/fsync) для лучшей производительности в Proton
    PROTON_NO_ESYNC = "1";                                                                      # Отключает старую синхронизацию esync (Eventfd), так как используется NTSync
    PROTON_NO_FSYNC = "1";                                                                      # Отключает старую синхронизацию fsync (Futex), так как используется NTSync
    LIBVA_DRIVER_NAME = "nvidia";                                                               # Указывает FFmpeg и браузерам использовать аппаратное кодирование/декодирование через NVIDIA (VA-API)
    TESSDATA_PREFIX = "/run/current-system/sw/share/tessdata";                                  # Путь к языковым данным Tesseract для OCR в Spectacle
  };


  # ========== Настройки файервола с nftables ==========
  networking.nftables.enable = true;                                                            # Переход на nftables (современная замена iptables)
  networking.firewall = {                                                                       # Основные настройки межсетевого экрана
    enable = true;                                                                              # Включаем файервол
    allowedTCPPorts = [ 22 ];                                                                   # Разрешаем входящие TCP-соединения на порт 22 (SSH)
    allowPing = false;                                                                          # Отключить ICMP-запросы (ping)
    logRefusedConnections = false;                                                              # Логирование отклонённых подключений (refused connections) Отключаем, чтобы не засорять логи
    logRefusedPackets = false;                                                                  # Логирование отклонённых пакетов (refused packets) Отключаем для снижения шума
  };


  # ========== Настройки звука ==========
  security.rtkit.enable = true;                                                                 # Включаем rtkit (Realtime Kit) — демон, дающий процессам приоритет реального времени. Необходим для низких задержек в аудио.
  services.pulseaudio.enable = false;                                                           # Отключаем старый звуковой сервер PulseAudio (полностью заменяем на PipeWire)

  security.pam.loginLimits = [                                                                  # Лимиты для аудио-группы (чтобы приложения имели приоритет реального времени и блокировку памяти)
    { domain = "@audio"; item = "rtprio"; type = "soft"; value = "89"; }                        # Мягкий лимит приоритета RT
    { domain = "@audio"; item = "rtprio"; type = "hard"; value = "89"; }                        # Жёсткий лимит приоритета RT
    { domain = "@audio"; item = "memlock"; type = "soft"; value = "unlimited"; }                # Мягкий лимит блокировки памяти
    { domain = "@audio"; item = "memlock"; type = "hard"; value = "unlimited"; }                # Жёсткий лимит блокировки памяти
  ];


  services.pipewire = {                                                                         # Основные настройки PipeWire
    enable = true;                                                                              # Включаем PipeWire как основной звуковой сервер
    alsa.enable = true;                                                                         # Поддержка ALSA (эмуляция для старых приложений)
    alsa.support32Bit = true;                                                                   # Поддержка 32-битных ALSA-клиентов (для игр и старого софта)
    jack.enable = true;                                                                         # Поддержка JACK (для профессиональных аудио-приложений)
    pulse.enable = true;                                                                        # Эмуляция PulseAudio (чтобы приложения, ожидающие PulseAudio, работали)
    wireplumber.enable = true;                                                                  # WirePlumber — менеджер сессий для PipeWire (более современный, чем старый media-session)
    extraConfig = {                                                                             # Дополнительная конфигурация для низкой задержки (low-latency)
      pipewire."99-low-latency" = {                                                             # Создаём профиль с именем "99-low-latency"
        "context.properties" = {                                                                # Основные свойства контекста PipeWire
          "default.clock.rate" = 48000;                                                         # Частота дискретизации по умолчанию (48 кГц)
          "default.clock.quantum" = 512;                                                        # Размер кванта (буфера) по умолчанию – 512 семплов (~10,6 мс при 48 кГц)
          "default.clock.min-quantum" = 128;                                                    # Минимальный размер кванта – 128 семплов (~2,7 мс при 48 кГц) – для снижения задержки (256 семплов (~5,3 мс))
          "default.clock.max-quantum" = 2048;                                                   # Максимальный размер кванта – 2048 семплов (~42,7 мс) – для стабильности
          "default.clock.allowed-rates" = [ 44100 48000 ];                                      # Разрешённые частоты дискретизации (44.1 и 48 кГц)
        };
        "context.modules" = [                                                                   # Загружаемые модули с параметрами реального времени
          {
            name = "libpipewire-module-rt";                                                     # Модуль для поддержки реального времени (realtime)
            args = {
              "nice.level" = -11;                                                               # Приоритет (nice) – отрицательное значение даёт более высокий приоритет
              "rt.prio" = 85;                                                                   # Приоритет реального времени (rtprio) – 85 (требует прав через rtkit)
            };
          }
        ];
      };
    };
  };


  # ========== Настройки FUSE для rclone (и других FUSE-файловых систем) ==========
  programs.fuse = {
    enable = true;                                                                              # Включает поддержку FUSE в системе
    userAllowOther = true;                                                                      # Разрешает опцию allow_other для обычных пользователей
    mountMax = 1000;                                                                            # Максимальное количество FUSE-монтирований на пользователя
  };


  # ========== Настройки сборки Nix ==========
  nix = {
    gc = {                                                                                      # Настройки автоматической очистки старых поколений (garbage collection)
      automatic = true;                                                                         # Включить автоматическую сборку мусора
      dates = "weekly";                                                                         # Расписание: еженедельно (можно изменить на "daily", "monthly")
      options = "--delete-older-than 7d";                                                       # Удалять поколения старше 7 дней
    };
    settings = {                                                                                # Дополнительные параметры оптимизации и поведения
      auto-optimise-store = true;                                                               # Автоматически оптимизировать store (удалять дубликаты файлов)
      max-jobs = 6;                                                                             # Максимальное количество параллельных сборок (задач Nix)
      keep-derivations = true;                                                                  # Сохранять деривации (промежуточные результаты сборки) – полезно для кэширования
      keep-outputs = true;                                                                      # Сохранять готовые outputs пакетов (обычно всегда true)
      substituters = [                                                                          # Список дополнительных кэшей (substituters), откуда Nix может скачивать готовые бинарные сборки
        "https://cache.nixos.org"                                                               # Основной кэш NixOS
        "https://cache.flox.dev"                                                                # Официальный кэш NVIDIA/CUDA (предотвращает компиляцию CUDA из исходников)
        "https://cache.nixos-cuda.org"                                                          # 🚀 Специализированный CUDA-кэш
        "https://nix-community.cachix.org"                                                      # Кэш Nix Community
      ];
      trusted-public-keys = [                                                                   # Публичные ключи для проверки подписей пакетов из соответствующих кэшей
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="                        # Ключ основного кэша
        "flox-cache-public-1:7F4OyH7ZCnFhcze3fJdfyXYLQw/aV7GEed86nQ7IsOs="                      # Ключ кэша flox (CUDA)
        "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M="                     # 🚀 Публичный ключ CUDA-кэша
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="               # ключ кэша nix-community
      ];
    };
  };


  programs.nh = {
    enable = true;                                                                              # Включает утилиту nh (Nix Helper) для удобного управления системой и home-менеджером
    flake = "/home/lucerno/${myLib.configDirName}";                                             # Указывает путь к flake, содержащему конфигурации NixOS и home-manager
  };


}
