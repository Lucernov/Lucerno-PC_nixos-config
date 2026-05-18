# modules/default.nix
{ config, pkgs, lib, pkgs-unstable, inputs, ... }:
                                                                                                                          # НАДО ДОРАЗОБРАТЬСЯ С ГИТ

{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  system.stateVersion = "25.11";

  imports = [
    ../hardware-configuration.nix
    ./nx_configuration-kde_plasma.nix
    ./nx_soft.nix
  ];


    # ========== мои симлинки ==========
  systemd.tmpfiles.rules = [
    "d /home/lucerno/.local/share 0755 lucerno lucerno -"
    "d /home/lucerno/.config 0755 lucerno lucerno -"
    "L+ /home/lucerno/drum_sklad - - - - /mnt/sys_archiv/samples/drum_sklad"
    "L+ /home/lucerno/.local/share/Steam/userdata - - - - /home/lucerno/nixos-config/dotfiles/config/Steam/userdata"
    "L+ /home/lucerno/.local/share/vital - - - - /mnt/sys_archiv/samples/vital"
    "L+ /home/lucerno/.config/AmneziaVPN.ORG - - - - /home/lucerno/nixos-config/dotfiles/config/AmneziaVPN.ORG"
    "L+ /home/lucerno/.config/obs-studio - - - - /home/lucerno/nixos-config/dotfiles/config/obs-studio"
    "L+ /home/lucerno/.config/DecentSampler - - - - /mnt/sys_archiv/samples/DecentSampler"
    "L+ /home/lucerno/.config/REAPER - - - - /home/lucerno/nixos-config/dotfiles/config/REAPER"
    "L+ /home/lucerno/.config/yabridgectl - - - - /home/lucerno/nixos-config/dotfiles/config/yabridgectl"
    "L+ /home/lucerno/.config/MangoHud - - - - /home/lucerno/nixos-config/dotfiles/config/MangoHud"
    "L+ /home/lucerno/.local/share/Steam/steamapps - - - - /mnt/games/SteamLibrary/steamapps"

    "L+ /home/lucerno/.config/kglobalshortcutsrc - - - - /home/lucerno/nixos-config/dotfiles/config/KDE/config-kglobalshortcutsrc"
    "L+ /home/lucerno/.local/share/applications/net.local.kitten - - - - /home/lucerno/nixos-config/dotfiles/config/KDE/local-share-applications-net.local.kitten"
  ];


  # ========== Загрузчик ==========
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
    systemd-boot.consoleMode = "max";
  };
  boot.supportedFilesystems = [ "exfat" ];
  #system.nixos-init.enable = true;                        # иногда проверять, пока проблемы с нвидиа

  boot.extraModprobeConfig = ''
    options btusb enable_autosuspend=0
  '';


  # ========== Настройки времени и локали ==========
  time.timeZone = "Europe/Moscow";      # Часовой пояс (Europe/Moscow)
  i18n.defaultLocale = "ru_RU.UTF-8";   # Основная локаль системы – русская, кодировка UTF-8
  i18n.extraLocaleSettings = {          # Дополнительные настройки локализации для отдельных категорий
    LC_ADDRESS = "ru_RU.UTF-8";         # Формат адресов
    LC_IDENTIFICATION = "ru_RU.UTF-8";  # Метаданные локали
    LC_MEASUREMENT = "ru_RU.UTF-8";     # Единицы измерения (метрическая система)
    LC_MONETARY = "ru_RU.UTF-8";        # Формат денежных единиц (рубли)
    LC_NAME = "ru_RU.UTF-8";            # Формат имён
    LC_NUMERIC = "ru_RU.UTF-8";         # Формат чисел (разделители десятичной части и тысяч)
    LC_PAPER = "ru_RU.UTF-8";           # Формат бумаги (A4)
    LC_TELEPHONE = "ru_RU.UTF-8";       # Формат телефонных номеров
    LC_TIME = "ru_RU.UTF-8";            # Формат времени (24-часовой, день.месяц.год)
  };


  # ========== Настройка пользователя lucerno ==========
  users.groups.lucerno = {};
  users.users.lucerno = {                                                            # Основные настройки учётной записи
    isNormalUser = true;                                                             # Обычный пользователь (не системный)
    hashedPasswordFile = "/home/lucerno/nixos-config/secrets/lucerno-password.hash"; # Файл с хешем пароля
    group = "lucerno";                                                               # Группа, к которой принадлежит пользователь
    extraGroups = [ "wheel" "networkmanager" "audio" "video" "storage" "render" ];
    shell = pkgs.zsh;                                                                # Командная оболочка по умолчанию (Zsh)
  };
  # ========== Настройка sudo ==========
  security.sudo = {
    enable = true;                                                                   # Включаем sudo
    wheelNeedsPassword = false;                                                      # Для членов группы wheel не требовать пароль. Пароль всё равно нужен для входа в систему.
  };


  # ========== Переменные окружения для Wayland и NVIDIA ==========
  environment.sessionVariables = {
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";                                                  # Принудительно указываем Vulkan-драйвер NVIDIA для OpenGL/GLX приложений (чтобы программы использовали NVidia, а не, например, llvmpipe)
    __GL_VRR_ALLOWED = "1";                                                                # Разрешает Variable Refresh Rate (VRR / G-Sync / FreeSync) Включает адаптивную синхронизацию для совместимых мониторов
    GBM_BACKEND = "nvidia-drm";                                                            # Указывает бэкенд Graphics Buffer Manager (GBM) от NVIDIA. Необходимо для корректной работы Wayland с проприетарным драйвером
    CHROME_FLAGS = "--ozone-platform-hint=auto";                                           # Флаги для браузеров на базе Chromium (Chrome, Edge, Brave и др.) Принудительно включает поддержку Wayland через Ozone
    ELECTRON_OZONE_PLATFORM_HINT = "auto";                                                 # Для приложений на Electron (VS Code, Discord, Telegram и др.) Заставляет их использовать Wayland вместо XWayland
    QT_QPA_PLATFORM = "wayland";                                                           # Задаёт бэкенд Qt для работы через Wayland (вместо X11)
    GDK_BACKEND = "wayland";                                                               # Указывает GTK-приложениям использовать Wayland
    SDL_VIDEODRIVER = "wayland";                                                           # Задаёт драйвер для SDL (используется в играх и мультимедиа) – Wayland
    QT_QPA_PLATFORM_PLUGIN_PATH = "${pkgs.qt6.qtwayland}/lib/qt-6/plugins/platforms";      # Путь к плагинам Qt для поддержки Wayland. Без этого некоторые Qt-приложения могут не запускаться под Wayland
    NIXOS_OZONE_WL = "1";
    WLR_NO_HARDWARE_CURSORS = "1";
    EGL_PLATFORM = "wayland";
    #WLR_RENDERER_ALLOW_SOFTWARE = "1";
  };


  # ========== Настройки файервола с nftables ==========
  networking.nftables.enable = true;           # Переход на nftables (современная замена iptables)
  networking.firewall = {                      # Основные настройки межсетевого экрана
    enable = true;                             # Включаем файервол
    allowedTCPPorts = [ 22 ];                  # Разрешаем входящие TCP-соединения на порт 22 (SSH)
    allowPing = true;                          # Разрешаем ICMP-запросы (ping) – полезно для диагностики сети
    logRefusedConnections = false;             # Логирование отклонённых подключений (refused connections) Отключаем, чтобы не засорять логи
    logRefusedPackets = false;                 # Логирование отклонённых пакетов (refused packets) Отключаем для снижения шума
  };


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


  # ========== Настройки сборки Nix ==========
  nix = {
    settings.auto-optimise-store = true;   # Автоматически оптимизировать store (удалять дубликаты файлов)
    gc = {                                 # Настройки автоматической очистки старых поколений (garbage collection)
      automatic = true;                    # Включить автоматическую сборку мусора
      dates = "weekly";                    # Расписание: еженедельно (можно изменить на "daily", "monthly")
      options = "--delete-older-than 7d";  # Удалять поколения старше 7 дней
    };

    # Дополнительные параметры оптимизации и поведения
    settings = {
      max-jobs = 6;                         # Максимальное количество параллельных сборок (задач Nix)
      keep-derivations = true;              # Сохранять деривации (промежуточные результаты сборки) – полезно для кэширования
      keep-outputs = true;                  # Сохранять готовые outputs пакетов (обычно всегда true)
    };
  };


}
