{ config, pkgs, myLib, ... }:

{
  system.stateVersion = myLib.stateVersion;                                                                 # Версия формата состояния системы. НЕ привязана к channelVersion!

  # ========== Настройки времени и локали ==========
  time = { timeZone = "Europe/Moscow"; };                                                                   # Часовой пояс (Europe/Moscow)
  i18n = {
    defaultLocale = "ru_RU.UTF-8";                                                                          # Основная локаль системы – русская, кодировка UTF-8
    extraLocaleSettings = {                                                                                 # Дополнительные настройки локализации для отдельных категорий
      LC_ADDRESS = "ru_RU.UTF-8";                                                                           # Формат адресов
      LC_IDENTIFICATION = "ru_RU.UTF-8";                                                                    # Метаданные локали
      LC_MEASUREMENT = "ru_RU.UTF-8";                                                                       # Единицы измерения (метрическая система)
      LC_MONETARY = "ru_RU.UTF-8";                                                                          # Формат денежных единиц (рубли)
      LC_NAME = "ru_RU.UTF-8";                                                                              # Формат имён
      LC_NUMERIC = "ru_RU.UTF-8";                                                                           # Формат чисел (разделители десятичной части и тысяч)
      LC_PAPER = "ru_RU.UTF-8";                                                                             # Формат бумаги (A4)
      LC_TELEPHONE = "ru_RU.UTF-8";                                                                         # Формат телефонных номеров
      LC_TIME = "ru_RU.UTF-8";                                                                              # Формат времени (24-часовой, день.месяц.год)
    };
  };

  # ========== Пользователи и группы ==========
  users = {
    groups = {
      ${myLib.userName} = {};                                                                               # Создать группу пользователя
      powercap = {};                                                                                        # Группа для доступа к энергопотреблению CPU (RAPL) нужна для отображения в btop
      fuse = {};                                                                                            # Группа для доступа к FUSE (монтирование в пользовательском пространстве), необходима для rclone
      nvidia = {};                                                                                          # Группа для доступа к устройствам NVIDIA (видеокарта, CUDA), необходима для работы с GPU и аппаратного ускорения
      idevice = {};                                                                                         # Группа для доступа к устройствам Apple (iPhone, iPad) через USB
    };
    users.${myLib.userName} = {                                                                             # Основные настройки учётной записи
      isNormalUser = true;                                                                                  # Обычный пользователь
      hashedPasswordFile = config.age.secrets."lucerno-password.hash".path;                                 # Файл с хешем пароля (расшифровывается agenix)
      group = myLib.userName;                                                                               # Группа, к которой принадлежит пользователь
      extraGroups = [
        "audio"                                                                                             # Для низкоуровневого доступа к звуку (ALSA, PipeWire, PulseAudio)
        "fuse"                                                                                              # Доступ к FUSE (монтирование в пользовательском пространстве для rclone и др.)
        "idevice"                                                                                           # Доступ к устройствам Apple (iPhone, iPad) через USB. Нужен для работы демона usbmuxd
        "libvirtd"                                                                                          # Управление виртуальными машинами через QEMU/KVM (libvirt)
        "networkmanager"                                                                                    # Управление сетями через NetworkManager (Wi‑Fi, VPN)
        "nvidia"                                                                                            # Доступ к драйверу NVIDIA (CUDA, OpenCL, аппаратное ускорение)
        "powercap"                                                                                          # Доступ к энергопотреблению CPU через RAPL (используется btop, powertop)
        "render"                                                                                            # Доступ к рендерингу через DRM (аппаратное ускорение графики)
        "rtkit"                                                                                             # Приоритет реального времени для аудио (Realtime Kit)
        "storage"                                                                                           # Управление дисками и хранилищами (монтирование, форматирование)
        "video"                                                                                             # Доступ к видеоустройствам и аппаратному ускорению (VA‑API, VDPAU)
        "wheel"                                                                                             # Доступ к командам sudo (администрирование системы)
      ];
      shell = pkgs.zsh;                                                                                     # Командная оболочка по умолчанию (Zsh)
    };
  };

  # ========== Безопасность (sudo) ==========
  security = {
    sudo = {
      enable = true;                                                                                        # Включить sudo
      wheelNeedsPassword = false;                                                                           # Для членов группы wheel не требовать пароль
      extraRules = [                                                                                        # Дополнительные правила sudo
        {
          users = [ myLib.userName ];                                                                       # Правило применяется к пользователю
          commands = [
            {
              command = "${pkgs.linuxPackages_zen.cpupower}/bin/cpupower frequency-set -g *";               # Разрешить менять CPU governor (performance / schedutil / powersave)
              options = [ "NOPASSWD" ];                                                                     # Без запроса пароля
            }
          ];
        }
      ];
    };
  };

  # ========== Переменные окружения ==========
  environment = {
    sessionVariables = {
      FLAKE = "${myLib.home}/${myLib.configDirName}";                                                       # Путь к flake. Читается nh, nixos-rebuild, home-manager — позволяет запускать их без --flake из любого места
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";                                                                 # Принудительно указывать Vulkan-драйвер NVIDIA для OpenGL/GLX приложений
      __GL_VRR_ALLOWED = "1";                                                                               # Разрешить Variable Refresh Rate (VRR / G-Sync / FreeSync). Включает адаптивную синхронизацию для совместимых мониторов
      GBM_BACKEND = "nvidia-drm";                                                                           # Указать бэкенд Graphics Buffer Manager (GBM) от NVIDIA. Необходимо для корректной работы Wayland с проприетарным драйвером
      ELECTRON_FORCE_WAYLAND = "1";                                                                         # Принудительно запустить Electron-приложения в нативном режиме Wayland вместо XWayland
      ELECTRON_OZONE_PLATFORM_HINT = "auto";                                                                # Для приложений на Electron (VS Code, Discord, Telegram и др.) Заставляет их использовать Wayland вместо XWayland
      QT_QPA_PLATFORM = "wayland";                                                                          # Задать бэкенд Qt для работы через Wayland (вместо X11)
      GDK_BACKEND = "wayland";                                                                              # Указать GTK-приложениям использовать Wayland
      SDL_VIDEODRIVER = "wayland,x11";                                                                      # Разрешить SDL использовать Wayland с fallback на X11 (иначе в Steam игра Steep падает с "Unable to initialize Vulkan")
      NIXOS_OZONE_WL = "1";                                                                                 # Включить поддержку Ozone Wayland для Chromium/Electron (флаг NIXOS_OZONE_WL)
      WLR_NO_HARDWARE_CURSORS = "1";                                                                        # Отключить аппаратные курсоры в wlroots (помогает избежать проблем с мерцанием курсора на NVIDIA)
      EGL_PLATFORM = "wayland";                                                                             # Указать EGL использовать Wayland (необходимо для некоторых приложений)
      PROTON_USE_NTSYNC = "1";                                                                              # Включить улучшенную синхронизацию NTSync (вместо устаревших esync/fsync) для лучшей производительности в Proton
      TESSDATA_PREFIX = "/run/current-system/sw/share/tessdata";                                            # Путь к языковым данным Tesseract для OCR в Spectacle
      XMODIFIERS = "@im=none";                                                                              # Говорит Xlib не пытаться открыть XIM (убирает "XOpenIM() failed" в логе Steam)
    };
  };

  # ========== Логи ==========
  services = {
    journald.extraConfig = ''
      # максимальный общий размер постоянных логов (в /var/log/journal)
      SystemMaxUse=300M
      # максимальный размер одного файла журнала (ротация происходит при достижении этого размера)
      SystemMaxFileSize=100M
      # аналогично для временных логов (в /run/log/journal), которые хранятся до перезагрузки
      RuntimeMaxUse=300M
      # размер одного файла для runtime-логов
      RuntimeMaxFileSize=100M
      # автоматическая очистка по времени (3 дня)
      SystemMaxRetentionSec=3d
    '';
  };

  # ========== Базовые настройки Nix ==========
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];                                                   # Включить поддержку команд Nix и флейков (flake)
      auto-optimise-store = true;                                                                           # Автоматически оптимизировать store (удалять дубликаты файлов)
      max-jobs = 4;                                                                                         # Максимальное количество параллельных сборок (задач Nix)
      keep-derivations = true;                                                                              # Сохранять деривации (промежуточные результаты сборки) – полезно для кэширования
      keep-outputs = true;                                                                                  # Сохранять готовые outputs пакетов (обычно всегда true)
      substituters = [                                                                                      # Список дополнительных кэшей (substituters), откуда Nix может скачивать готовые бинарные сборки
        "https://cache.nixos.org"                                                                           # Основной кэш NixOS
        "https://nix-community.cachix.org"                                                                  # Кэш Nix Community
        "https://cache.nixos-cuda.org"                                                                      # Специализированный CUDA-кэш
        "https://cache.flox.dev"                                                                            # Официальный кэш NVIDIA/CUDA (предотвращает компиляцию CUDA из исходников)
        "https://adithyagenie.cachix.org"                                                                   # Кэш готовых сборок Blender с CUDA (от adithyagenie, экономит время компиляции)
        "https://comfyui.cachix.org"                                                                        # Кэш готовых сборок ComfyUI (в т.ч. CUDA-wheels PyTorch) – избавляет от многочасовой компиляции из исходников
      # "https://devenv.cachix.org"                                                                         # Кеш для сред разработки (devenv)
      # "https://chaotic-nyx.cachix.org"                                                                    # Дополнительный кеш с большим количеством популярных пакетов
      # "https://attic.xuyh0120.win/lantian"                                                                # Добавляем кэш аттика от xuyh0120 (содержит множество готовых сборок для CachyOS пакетов)
      ];
      trusted-public-keys = [                                                                               # Публичные ключи для проверки подписей пакетов из соответствующих кэшей
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="                                    # Ключ основного кэша
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="                           # ключ кэша nix-community
        "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M="                                 # Публичный ключ CUDA-кэша
        "cache.flox.dev-1:H4Tsx+8AOz3b3CvyCqVQPyEr2cHKH+O8bHn8ZgYp/po="                                     # Ключ кэша flox (CUDA)
        "adithyagenie.cachix.org-1:h6BSMboeVfxyrULWuRQqAyweo4AJRATekb88xotfQwc="                            # Публичный ключ кэша adithyagenie (Blender с CUDA)
        "comfyui.cachix.org-1:33mf9VzoIjzVbp0zwj+fT51HG0y31ZTK3nzYZAX0rec="                                 # Публичный ключ кэша ComfyUI (официальный ключ из flake.nix проекта utensils/comfyui-nix)
      # "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="                                  # Ключ devenv
      # "chaotic-nyx.cachix.org-1:HfnXSw4pj95iI/n17rIDy40agHj12WfF+Gqk6SonIT8="                             # Ключ chaotic-nyx
      # "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="                                              # Публичный ключ для проверки подписей пакетов из указанного аттика.
      ];
    };
    gc = {                                                                                                  # Настройки автоматической очистки старых поколений (garbage collection)
      automatic = true;                                                                                     # Включить автоматическую сборку мусора
      dates = "weekly";                                                                                     # Расписание: еженедельно (можно изменить на "daily", "monthly")
      options = "--delete-older-than 7d";                                                                   # Удалять поколения старше 7 дней
    };
  };

}
