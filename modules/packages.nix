# modules/packages.nix
{ pkgs, pkgs-unstable, myLib, blender-cuda, ... }:

{
  # ========== Включение системных модулей для программ ==========
  programs = {
    git = {
      enable = true;                                              # Включает поддержку Git
      lfs.enable = true;                                          # Git LFS для работы с большими файлами
    };
    nix-index.enable = true;                                      # Автоматически обновлять индекс для nix-locate при каждом переключении поколения
    dconf.enable = true;                                          # Включает dconf – базу данных настроек для GTK-приложений
    zsh.enable = true;                                            # Регистрирует Zsh как системную оболочку
    vim.enable = true;                                            # Устанавливает Vim (текстовый редактор)
    nano.enable = true;                                           # Устанавливает Nano (простой текстовый редактор)
    htop.enable = true;                                           # Устанавливает htop (интерактивный монитор процессов)
    amnezia-vpn.enable = true;                                    # Включает сервис AmneziaVPN (VPN-клиент)
    virt-manager.enable = true;                                   # Включает Virtual Machine Manager (графический интерфейс для управления QEMU/KVM через libvirt)
    appimage = {
      enable = true;                                              # Включает поддержку запуска AppImage-файлов
      binfmt = true;                                              # Автоматически настраивает загрузчик
    };
    nh = {
      enable = true;                                              # Включает утилиту nh (Nix Helper)
      flake = "${myLib.home}/${myLib.configDirName}";             # Указывает путь к flake
    };
    steam = {
      enable = true;                                              # Включает поддержку Steam (устанавливает пакет, добавляет 32-битную среду)
      remotePlay.openFirewall = true;                             # Открывает порты в фаерволе для Steam Remote Play (трансляция игры на другие устройства)
      dedicatedServer.openFirewall = true;                        # Открывает порты для выделенных серверов игр (например, для Counter-Strike, Garry's Mod)
      extraCompatPackages = [ pkgs-unstable.proton-ge-bin ];      # Дополнительные совместимые пакеты (Proton-GE) для запуска Windows-игр
    };
    obs-studio = {
      enable = true;                                              # Включает поддержку OBS
      package = pkgs.obs-studio.override { cudaSupport = true; }; # Основной пакет с CUDA
      enableVirtualCamera = true;                                 # Включает виртуальную веб-камеру (v4l2loopback)
      plugins = with pkgs.obs-studio-plugins; [                   # Подключение плагинов
        wlrobs                                                    # Захват экрана под Wayland
        obs-vaapi                                                 # Аппаратное кодирование через VA-API
        obs-pipewire-audio-capture                                # Захват звука через PipeWire
        obs-multi-rtmp                                            # Мультистриминг
        obs-backgroundremoval                                     # Удаление фона
        obs-vintage-filter                                        # Винтажные эффекты
        obs-source-clone                                          # Клонирование источников
        droidcam-obs                                              # вебкамера через яблофон
      ];
    };
    firefox = {
      enable = true;                                              # Установка браузера Firefox
      languagePacks = [ "ru" ];                                   # Загружает РУ языковой файл (переводы) в систему
      preferences = {                                             # Базовые настройки about:config
        "intl.locale.requested" = "ru";                           # Включить русский язык интерфейса
        "browser.startup.homepage" = "https://duckduckgo.com";    # Домашняя страница при запуске браузера
        "browser.search.defaultenginename" = "DuckDuckGo";        # Поисковая система по умолчанию (используется в адресной строке и поиске)
        "dom.security.https_only_mode" = true;                    # Принудительное использование HTTPS для всех сайтов (повышает безопасность)
        "browser.search.region" = "RU";                           # Регион для поиска (Россия)
        "extensions.pocket.enabled" = false;                      # Отключаем Pocket (не всем нужно)
        "browser.urlbar.suggest.searches" = false;                # Не отправлять поисковые запросы в адресной строке
      };
      policies = {                                                # Корпоративные политики (имеют приоритет над preferences)
        DisableTelemetry = true;                                  # Отключает телеметрию
        DisablePocket = true;                                     # Отключает Pocket полностью
        EnableTrackingProtection = true;                          # Включает защиту от отслеживания
      };
    };
    # KDE приложения
    partition-manager.enable = true;                              # Включает модуль для KDE Partition Manager
    kdeconnect.enable = true;                                     # Включает интеграцию с телефоном через KDE Connect
  };

  environment.systemPackages = with pkgs; [
    # СИСТЕМНЫЕ
    oh-my-zsh                                                     # Пакет Oh My Zsh (фреймворк для управления конфигурацией Zsh)
    zsh-powerlevel10k                                             # Тема для Zsh с красивым информативным промптом (Powerlevel10k)
    zsh-syntax-highlighting                                       # Подсветка синтаксиса команд в Zsh (подключается в .zshrc)
    zsh-autosuggestions                                           # Автоподсказки на основе истории в Zsh (подключается в .zshrc)
    manix                                                         # Универсальный поиск по документации Nix
    nix-tree                                                      # Просмотр дерева зависимостей Nix
    nil                                                           # LSP-сервер для Nix
    nix-du                                                        # Анализирует использование дискового пространства в Nix store
    nix-output-monitor                                            # Отслеживает сборку Nix и показывает прогресс зависимостей
    cachix                                                        # Утилита для работы с кэшем Nix (добавление/управление бинарными кэшами)
    any-nix-shell                                                 # Позволяет использовать Nix-оболочки из любого терминала. Упрощает работу с временными окружениями
    nixpkgs-fmt                                                   # Форматтер Nix (автоматическое форматирование кода)
    statix                                                        # Линтер Nix (статический анализ)
    deadnix                                                       # Поиск мёртвого (неиспользуемого) кода в Nix
    openh264                                                      # Кодек H.264 от Cisco с открытым исходным кодом. Используется для аппаратного кодирования
    ffmpeg-full                                                   # Полная версия FFmpeg (кодирование/декодирование аудио/видео)
    yt-dlp                                                        # Утилита для загрузки видео/аудио с YouTube и сотен других сайтов (форк youtube-dl) нужен для cliamp
    libva-utils                                                   # Утилиты для VA-API (аппаратное ускорение видео)
    wayland-utils                                                 # Набор утилит для диагностики Wayland (например, wayland-info)
    lact                                                          # Утилита для управления видеокартами NVIDIA и AMD (мониторинг, разгон, управление вентиляторами, настройка VF-кривой). Для NVIDIA требуется библиотека NVML
    uv                                                            # Менеджер Python-проектов (альтернатива pip + virtualenv)
    gsettings-desktop-schemas                                     # Схемы настроек для GSettings (используются GTK-приложениями)
    base16-schemes                                                # Набор цветовых схем Base16 (для терминалов, редакторов)
    gearlever                                                     # Менеджер обновлений для AppImages приложений
    mission-center                                                # Графический монитор системы (альтернатива btop)
    strace                                                        # перехватывает и записывает все системные вызовы (поиск ошибок запуска программ)
    usbutils                                                      # Набор утилит для работы с USB (lsusb, usb-devices, диагностика USB-устройств)
    alsa-utils                                                    # Утилиты для работы с ALSA (aplay, arecord, alsamixer, управление звуковыми картами)
    zenity                                                        # Утилита для графических диалогов (GTK). Требуется Sforzando для выбора папки Aria Engine при первом запуске

    # ========== КОНСОЛЬНЫЕ УТИЛИТЫ ==========
    kitty                                                         # Эмулятор терминала с поддержкой GPU и лигатур
    lsd                                                           # Улучшенный аналог ls с иконками и цветами
    bat                                                           # Улучшенный cat с подсветкой синтаксиса и интеграцией с Git
    zoxide                                                        # Умная замена cd, запоминающая часто используемые папки
    fd                                                            # Простая и быстрая альтернатива find
    ripgrep                                                       # Очень быстрый grep для поиска по коду
    fzf                                                           # Интерактивный фильтр для командной строки (поиск)
    tree                                                          # Показывает дерево каталогов
    lazygit                                                       # TUI-интерфейс для Git (удобное управление репозиториями)
    mc                                                            # Midnight Commander – классический двухпанельный файловый менеджер
    yazi                                                          # Современный файловый менеджер на Rust с предпросмотром изображений и видео
    unzip                                                         # Распаковка ZIP-архивов
    rar                                                           # Работа с архивами RAR (сжатие и распаковка)
    fastfetch                                                     # Вывод информации о системе
    lsof                                                          # Просмотр открытых файлов и сокетов
    lnav                                                          # Просмотр лог-файлов с подсветкой и навигацией
    nvtopPackages.nvidia                                          # Монитор GPU NVIDIA в консоли (аналог htop для видеокарты)
    my-packages.btop                                              # Монитор ресурсов с графиками
    termshark                                                     # Анализатор сетевого трафика в терминале (альтернатива Wireshark)
    duf                                                           # Просмотр использования дискового пространства (удобная альтернатива df)
    dust                                                          # Анализ размера папок/файлов с визуализацией (аналог du, но нагляднее)
    cliamp                                                        # Консольный музыкальный плеер в стиле Winamp с поддержкой YouTube, Spotify, подкастов и визуализацией спектра
    cava                                                          # Консольный аудиовизуализатор (спектроанализатор для музыки)
    neo                                                           # Матричный дождь из символов (эффект из фильма)

    # KDE приложения
    kdePackages.breeze-gtk                                        # Обеспечивает единый внешний вид GTK-программ в окружении KDE Plasma
    kdePackages.kde-gtk-config                                    # Настройка GTK-тем для KDE (позволяет менять тему GTK через системные настройки Plasma)
    kdePackages.kcalc                                             # Калькулятор
    kdePackages.ktorrent                                          # Torrent-клиент
    #kdePackages.kdialog
    (tesseract.override { enableLanguages = [ "eng" "rus" ]; })   # Tesseract — движок оптического распознавания символов (OCR) + Добавляет языковые пакеты: английский и русский

    # ИНТЕРНЕТ
    iw                                                            # Утилита для настройки беспроводных сетей (Wi-Fi)
    fail2ban                                                      # Демон для блокировки подозрительных IP-адресов (защита от брутфорса)
    rclone                                                        # Утилита для синхронизации и монтирования облачных хранилищ (Google Drive, OneDrive и др.)
    wget                                                          # Утилита для загрузки файлов из интернета
    authenticator                                                 # Приложение для двухфакторной аутентификации (TOTP, HOTP), например, для аккаунтов Google, GitHub и т.д.
    parabolic                                                     # Загрузчик видео/аудио с YouTube (альтернатива yt-dlp)
  # (discord.override { withOpenASAR = true; })                   # Голосовой/текстовый чат
    (vesktop.override { withSystemVencord = false; })             # Голосовой/текстовый чат (альтернатиивный discord клиент в котором открываются видео ролики)
    telegram-desktop                                              # Мессенджер Telegram
    my-packages.teamspeak                                         # Голосовой чат Тимспик

    # ГРАФИКА
    upscaler                                                      # Увеличение разрешения изображений
    switcheroo                                                    # приложение для конвертации изображений
    optipng                                                       # Оптимизатор PNG файлов
    pinta                                                         # Простой растровый редактор
    krita                                                         # Кастомный пакет Krita (цифровая живопись) берется из NIXOS 25.11
    inkscape                                                      # Векторная графика

    # 3D-моделирование
    blender-cuda.packages.${pkgs.stdenv.hostPlatform.system}.blender-with-cuda  # 3D редактор (бинарная версия с поддержкой CUDA)
    freecad                                                       # 3D кад программа
  # dune3d                                                        # 3D кад программа
    prusa-slicer                                                  # Слайсер для 3D принтера
    printrun                                                      # Соединение с 3D принтером и отправка на печать по usb

    # МУЛЬТИМЕДИА
    my-packages.qmmp                                              # Аудиоплеер
    vlc                                                           # Универсальный видеоплеер
    mpv                                                           # Видеоплеер (корректно открывает AV1)
    droidcam                                                      # вебкамера через iphone

    # ОФИС
    eloquent                                                      # Проверка орфографии и стилистики текста (аналог LanguageTool)
    planify                                                       # Менеджер задач и проектов (GTK, синхронизация с Todoist, Nextcloud)
    libreoffice-qt-still                                          # Офисный пакет LibreOffice (стабильная ветка) с интеграцией в KDE Plasma через Qt
    hunspellDicts.ru_RU                                           # Словарь для проверки орфографии (русский язык)
    hyphenDicts.ru_RU                                             # Словарь для автоматической расстановки переносов (русский язык)

    # ИГРЫ
    minion                                                        # Менеджер аддонов для TESO
    (bottles.override { removeWarningPopup = true; })             # Запуск Windows-приложений через Wine (без всплывающих предупреждений)
    goverlay                                                      # Оверлей для мониторинга системы и FPS (MangoHud, vkBasalt)
    mangohud                                                      # Оверлей для отображения FPS и мониторинга системы в играх
    (retroarch.withCores (cores: with cores; [                    # Эмулятор приставок
      mesen                                                       # Ядро Nintendo NES
      bsnes                                                       # Ядро Nintendo SNES
      parallel-n64                                                # Ядро Nintendo 64 (Vulkan)
      genesis-plus-gx                                             # Ядро Sega Genesis / Mega Drive (плюс Master System, Game Gear, Sega CD)
      beetle-saturn                                               # Ядро Sega Saturn
      flycast                                                     # Ядро Sega Dreamcast
      ppsspp                                                      # Ядро PSP
      beetle-psx-hw                                               # Ядро PlayStation 1
      pcsx2                                                       # Ядро PlayStation 2
    ]))
  # lutris                                                        # Игровой лаунчер для управления играми
  # heroic                                                        # Лаунчер для Epic Games Store и GOG

    # ИИ
    comfy-ui-cuda                                                 # ComfyUI с поддержкой CUDA для генерации изображений через нейросети

    # ВИРТУАЛКА
    virtio-win                                                    # Драйверы VirtIO для Windows (не ISO, а папка с драйверами, подключается через CD-ROM как папка)

    # МУЗЫКА
      # --- DAW и среда ---
    my-packages.reaper                                            # REAPER – цифровая звуковая рабочая станция (DAW) БЕРЕТСЯ ИЗ НЕСТАБИЛЬНОГО КАНАЛА!!!
    wineWow64Packages.staging                                     # Wine с поддержкой 64 и 32 бит (staging‑патчи для аудио)
    yabridge                                                      # Мост для запуска Windows VST-плагинов в Linux (через Wine)
    yabridgectl                                                   # Утилита для управления yabridge (сканирование, синхронизация)
    winetricks                                                    # Вспомогательный скрипт для настройки Wine (установка DLL, зависимостей)
    coppwr                                                        # Графическая утилита для управления PipeWire (альтернатива pw-top)
      # --- Синтезаторы и Сэмплеры ---
    vital                                                         # Синтезатор FM (VST-плагин)
    my-packages.ostirus                                           # Эмуляция синтезатора Access Virus TI (CLAP)
    surge-xt                                                      # Синтезатор Surge XT
    my-packages.shortcircuit-xt                                   # Мощный открытый семплер (CLAP) от Surge Synth Team
    decent-sampler                                                # Сэмплер для библиотек DecentSampler (формат .dspreset, .dslibrary)
    my-packages.sforzando                                         # Семплер форматов SFZ v1 \ v2 и  ARIA
    my-packages.orchestools                                       # Набор оркестровых VST3-инструментов (Brass, Perc, Strings, Winds)
    my-packages.ot-piano-s                                        # Пианино OT P1ANO S (VST2)
      # --- Синтезаторы и Сэмплеры ударных ---
    my-packages.mtpdk                                             # лёгкий плагин ударной установки MT-PowerDrumKit 2
    my-packages.drumlabooh                                        # LV2-сэмплер ударных с несколькими наборами (drumlabooh)
    my-packages.drum-locker                                       # плагин ударной установки Drum Locker
    drumgizmo                                                     # Многоканальный сэмплер барабанов (реалистичные ударные)
    geonkick                                                      # Синтезатор барабанов для создания ударных партий
      # --- Гитарные процессоры и усилители ---
    my-packages.amp-locker                                        # плагин эмулирующий стек гитарного тракта Amp-Locker
    fretboard                                                     # Гитаровый гриф (примеры построения аккордов)
    lingot                                                        # гитарный тюнер
      # --- Эффекты (обработка звука) ---
    lsp-plugins                                                   # Набор VST/LV2-плагинов для обработки звука (LSP)
    calf                                                          # Calf Studio Gear один из самых известных и полных наборов аудио-плагинов для Linux
    my-packages.air-g-plugins                                     # Коллекция VST3-плагинов на основе Airwindows для микширования и мастеринга
    dragonfly-reverb                                              # Реверберация Dragonfly (VST/LV2)

    ] ++ (with pkgs-unstable; [                                   # Пакеты из нестабильного канала (более свежие версии)
    # МУЗЫКА
      # --- DAW и среда ---
    reaper-sws-extension                                          # Расширение SWS для REAPER (дополнительные команды и автоматизация)
    reaper-reapack-extension                                      # Менеджер скриптов ReaPack для REAPER (установка пользовательских скриптов)
      # --- Гитарные процессоры и усилители ---
    ratatouille-lv2                                               # плагин для загрузки и микширования нейросетевых моделей гитарных усилителей (аналог Neural Amp Model)

    # KDE приложения
    kdePackages.kdenlive                                          # Видеоредактор
  ]);

}

# ===== Быстрый запуск утилит без установки (через nix run) =====
#nix run nixpkgs#lm-sensors                                                 # Утилита для отображения температуры и состояния датчиков оборудования
#nix run nixpkgs#genact                                                     # Генератор бессмысленной активности в терминале (имитация работы, для прикола)

# ===== Генерация конфигов Plasma Manager =====
#nix run github:nix-community/plasma-manager/trunk#rc2nix > plasma.nix      # Сгенерировать текущий конфиг Plasma в Nix-формате (rc2nix)
#nix run github:nix-community/plasma-manager#rc2nix > plasma-current.nix    # Альтернативный способ (из главной ветки) получить Nix-конфиг Plasma
