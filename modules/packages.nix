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
    htop.enable = true;                                           # Устанавливает htop (монитор процессов)
  # amnezia-vpn.enable = true;                                    # Включает сервис AmneziaVPN (VPN-клиент)
    amnezia-vpn = {                                               # Включает сервис AmneziaVPN (VPN-клиент) 5.0.3.0
      enable = true;
      package = pkgs-unstable.amnezia-vpn;                        # из нестабильного канала
    };

    virt-manager.enable = true;                                   # Включает Virtual Machine Manager (графический интерфейс для управления QEMU/KVM через libvirt)
    appimage = {
      enable = true;                                              # Включает поддержку запуска AppImage-файлов
      binfmt = true;                                              # Автоматически настраивает загрузчик
    };
    nh = {
      enable = true;                                              # Включает Nix Helper
      flake = "${myLib.home}/${myLib.configDirName}";             # Указывает путь к flake
    };
    steam = {
      enable = true;                                              # Включает поддержку Steam
      remotePlay.openFirewall = true;                             # Открывает порты в фаерволе для Steam Remote Play (трансляция игры на другие устройства)
      dedicatedServer.openFirewall = true;                        # Открывает порты для выделенных серверов игр (DST)
      extraCompatPackages = [ pkgs-unstable.proton-ge-bin ];      # Устанавливает Proton-GE
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
      preferences = {
        "intl.locale.requested" = "ru";                           # Включить русский язык интерфейса
        "browser.startup.homepage" = "https://duckduckgo.com";    # Домашняя страница при запуске браузера
        "browser.search.defaultenginename" = "DuckDuckGo";        # Поисковая система по умолчанию (используется в адресной строке и поиске)
        "browser.search.region" = "RU";                           # Регион для поиска (Россия)
        "browser.urlbar.suggest.searches" = false;                # Не отправлять поисковые запросы в адресной строке
        "dom.security.https_only_mode" = true;                    # Принудительное использование HTTPS для всех сайтов
        "extensions.pocket.enabled" = false;                      # Отключить Pocket
        "media.av1.enabled" = true;                               # Включить поддержку AV1 (RTX 3070 / Ampere умеет аппаратно декодировать AV1)
        "media.hardware-video-decoding.force-enabled" = true;     # Принудительно включить аппаратное декодирование (даже если Firefox сомневается)
      };
      policies = {                                                # Корпоративные политики (имеют приоритет над preferences)
        DisableTelemetry = true;                                  # Отключить телеметрию
        DisablePocket = true;                                     # Отключить Pocket полностью
        EnableTrackingProtection = true;                          # Включить защиту от отслеживания
      };
    };
    # KDE приложения
    partition-manager.enable = true;                              # Включить модуль для KDE Partition Manager
    kdeconnect.enable = true;                                     # Включить интеграцию с телефоном через KDE Connect
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
    cachix                                                        # Утилита для работы с кэшем Nix (добавление/управление бинарными кэшами)
    nix-your-shell                                                # Позволяет использовать Nix-оболочки из любого терминала. Упрощает работу с временными окружениями
    nixfmt                                                        # Форматтер Nix (автоматическое форматирование кода)
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
    adwaita-icon-theme                                            # Иконки GNOME (нужны Telegram, RetroArch, некоторым GTK-приложениям — убирает предупреждения в логах)
    gearlever                                                     # Менеджер обновлений для AppImages приложений
    mission-center                                                # Графический монитор системы (альтернатива btop)
    strace                                                        # перехватывает и записывает все системные вызовы (поиск ошибок запуска программ)
    usbutils                                                      # Набор утилит для работы с USB (lsusb, usb-devices, диагностика USB-устройств)
    alsa-utils                                                    # Утилиты для работы с ALSA (aplay, arecord, alsamixer, управление звуковыми картами)
    zenity                                                        # Утилита для графических диалогов (GTK). Требуется Sforzando для выбора папки Aria Engine при первом запуске
    file                                                          # Определение типа файла (ELF, PNG, tar, ...)
    libimobiledevice                                              # Библиотека и набор утилит для связи с устройствами Apple (iPhone, iPad) по USB
    ifuse                                                         # Утилита для монтирования файловой системы iPhone/iPad как обычной папки в Linux (через FUSE)
    vulkan-hdr-layer-kwin6                                        # Vulkan HDR Layer — посредник между HDR-игрой и драйвером NVIDIA (решает проблему "HDR не обнаружен")
    linuxPackages_zen.cpupower                                    # Утилита для управления частотой CPU (используется для смены governor)
    nix-update                                                    # Автообновление дериваций через GitHub/GitLab API
    fbset                                                         # Настройка разрешения framebuffer для TTY (используется в nx_tty.nix)
    ragenix                                                       # CLI agenix (Rust-реализация, совместима с ryantm/agenix)
    age                                                           # Утилита шифрования (генерация age-ключей)
  # rtcqs                                                         # Real-Time Config Quick Scan – диагностика системы для аудио (пока нет в NIXOS)

    # ========== КОНСОЛЬНЫЕ УТИЛИТЫ ==========
    bat                                                           # Улучшенный cat с подсветкой синтаксиса и интеграцией с Git
    lucerno-packages.btop                                         # Монитор ресурсов с графиками
    cava                                                          # Консольный аудиовизуализатор (спектроанализатор для музыки)
    cliamp                                                        # Консольный музыкальный плеер с поддержкой YouTube, Spotify, подкастов и радио
    duf                                                           # Просмотр использования дискового пространства (удобная альтернатива df)
    dust                                                          # Анализ размера папок/файлов с визуализацией (аналог du, но нагляднее)
    fastfetch                                                     # Вывод информации о системе
    fd                                                            # Простая и быстрая альтернатива find
    fzf                                                           # Интерактивный фильтр для командной строки (поиск)
    gping                                                         # Ping с графиком задержек в реальном времени (строит ASCII-график в терминале)
    kitty                                                         # Эмулятор терминала с поддержкой GPU и лигатур
    lazygit                                                       # TUI-интерфейс для Git (удобное управление репозиториями)
    lnav                                                          # Просмотр лог-файлов с подсветкой и навигацией
    lsd                                                           # Улучшенный аналог ls с иконками и цветами
    lsof                                                          # Просмотр открытых файлов и сокетов
    mc                                                            # Midnight Commander – классический двухпанельный файловый менеджер
    ncdu                                                          # Интерактивный анализатор использования дискового пространства (ncurses-версия du)
    neo                                                           # Матричный дождь из символов (эффект из фильма)
    nvtopPackages.nvidia                                          # Монитор GPU NVIDIA в консоли (аналог htop для видеокарты)
    onefetch                                                      # Вывод информации о репозитории
    rar                                                           # Работа с архивами RAR (сжатие и распаковка)
    ripgrep                                                       # Очень быстрый grep для поиска по коду
    termshark                                                     # Анализатор сетевого трафика в терминале (альтернатива Wireshark)
    tree                                                          # Показывает дерево каталогов
    unzip                                                         # Распаковка ZIP-архивов
    yazi                                                          # Современный файловый менеджер на Rust с предпросмотром изображений и видео
    zoxide                                                        # Умная замена cd, запоминающая часто используемые папки

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
    zapzap                                                        # Вотсап клииент
    lucerno-packages.teamspeak                                    # Голосовой чат Тимспик

    # ГРАФИКА
    upscaler                                                      # Увеличение разрешения изображений
    switcheroo                                                    # приложение для конвертации изображений
    curtail                                                       # Уменьшает размер изображений
    optipng                                                       # Оптимизатор PNG файлов
    pinta                                                         # Простой растровый редактор
    krita                                                         # Кастомный пакет Krita (цифровая живопись) берется из NIXOS 25.11
    inkscape                                                      # Векторная графика
    constrict                                                     # Графическая утилита для сжатия видео до заданного размера (GTK-приложение, обёртка над FFmpeg)

    # 3D-моделирование
    blender-cuda.packages.${pkgs.stdenv.hostPlatform.system}.blender-with-cuda  # 3D редактор (бинарная версия с поддержкой CUDA)
    freecad                                                       # 3D кад программа
  # dune3d                                                        # 3D кад программа
    prusa-slicer                                                  # Слайсер для 3D принтера
    printrun                                                      # Соединение с 3D принтером и отправка на печать по usb

    # МУЛЬТИМЕДИА
    lucerno-packages.qmmp                                         # Аудиоплеер
    vlc                                                           # Универсальный видеоплеер
    mpv                                                           # Видеоплеер (корректно открывает AV1)
    droidcam                                                      # вебкамера через iphone
    lucerno-packages.hdrezka.client                               # Консольный клиент HDrezka с поиском через fzf и воспроизведением через mpv

    # ОФИС
  # appflowy                                                      # Открытая альтернатива Notion: заметки, вики, базы данных, канбан-доски и календари с поддержкой ИИ
    eloquent                                                      # Проверка орфографии и стилистики текста (аналог LanguageTool)
    foliate                                                       # Программа для чтения электронных книг (EPUB, MOBI, AZW3, FB2) с поддержкой словарей и закладок
    hunspellDicts.ru_RU                                           # Словарь для проверки орфографии (русский язык)
    hyphenDicts.ru_RU                                             # Словарь для автоматической расстановки переносов (русский язык)
    libreoffice-qt-still                                          # Офисный пакет LibreOffice (стабильная ветка) с интеграцией в KDE Plasma через Qt
    planify                                                       # Менеджер задач и проектов (GTK, синхронизация с Todoist, Nextcloud)

    # ИГРЫ
    minion                                                        # Менеджер аддонов для TESO
    lucerno-packages.noita-save-manager                           # Менеджер сохранений для Noita
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
    rpcs3                                                         # Эмулятор PlayStation 3
  # lutris                                                        # Игровой лаунчер для управления играми
  # heroic                                                        # Лаунчер для Epic Games Store и GOG

    # ИИ
    comfy-ui-cuda                                                 # ComfyUI с поддержкой CUDA для генерации изображений через нейросети

    # ВИРТУАЛКА
    virtio-win                                                    # Драйверы VirtIO для Windows (не ISO, а папка с драйверами, подключается через CD-ROM как папка)
  # podman                                                        # Движок контейнеров без демона (альтернатива Docker), нужен для distrobox
  # distrobox                                                     # Утилита для запуска контейнеров с разными дистрибутивами Linux (используется distroshelf/boxbuddy)
  # distroshelf                                                   # Графический менеджер контейнеров Distrobox (GTK4, аналог Boxbuddy, использует Podman/Docker для запуска разных дистрибутивов Linux внутри основной системы)
  # boxbuddy                                                      # Графический интерфейс (GTK4) для управления контейнерами Distrobox (требует отдельной установки Podman и Distrobox)

    # МУЗЫКА
      # --- DAW и среда ---
    lucerno-packages.reaper                                       # REAPER – цифровая звуковая рабочая станция (DAW) БЕРЕТСЯ ИЗ НЕСТАБИЛЬНОГО КАНАЛА через оверлей!!!
    wineWow64Packages.staging                                     # Wine с поддержкой 64 и 32 бит (staging‑патчи для аудио)
    yabridge                                                      # Мост для запуска Windows VST-плагинов в Linux (через Wine)
    yabridgectl                                                   # Утилита для управления yabridge (сканирование, синхронизация)
    winetricks                                                    # Вспомогательный скрипт для настройки Wine (установка DLL, зависимостей)
    coppwr                                                        # Графическая утилита для управления PipeWire
      # --- Синтезаторы и Сэмплеры ---
    vital                                                         # Синтезатор FM (VST-плагин)
    lucerno-packages.ostirus                                      # Эмуляция синтезатора Access Virus TI (CLAP)
    lucerno-packages.je8086                                       # Эмуляция синтезатора Roland JP-8000 (CLAP)
    surge-xt                                                      # Синтезатор Surge XT
    lucerno-packages.shortcircuit-xt                              # Семплер (CLAP) от Surge Synth Team
    decent-sampler                                                # Сэмплер для библиотек DecentSampler (формат .dspreset, .dslibrary)
    lucerno-packages.sforzando                                    # Семплер форматов SFZ v1 \ v2 и  ARIA
    lucerno-packages.numa-player                                  # Виртуальный инструмент Studiologic Numa Player (VST3 + standalone)
    lucerno-packages.orchestools                                  # Набор оркестровых VST3-инструментов (Brass, Perc, Strings, Winds)
    lucerno-packages.ot-piano-s                                   # Пианино OT P1ANO S (VST2)
    ripplerx                                                      # Физически моделируемый синтезатор (модальный синтез) с двойными резонаторами, аналог AAS Chromaphone и Ableton Collision
  # Triple Cheese - !!! УСТАНОВЛЕНО !!!                           # Плагины U-he пишут в свой .so при работе. Тут устанавливать нельзя. Подробности установкии pkgs/pkg_Triple-Cheese.nix
      # --- Синтезаторы и Сэмплеры ударных ---
    lucerno-packages.mtpdk                                        # Лёгкий плагин ударной установки MT-PowerDrumKit 2 есть много пресетов партий
    lucerno-packages.drumlabooh                                   # LV2-сэмплер ударных с несколькими наборами (drumlabooh)
    lucerno-packages.drum-locker                                  # Плагин ударной установки Drum Locker
    drumgizmo                                                     # Многоканальный сэмплер барабанов (сырые барабашки)
    drumkv1                                                       # Old-school сэмплер ударных (LV2) в стиле старых драм-машин со стерео-эффектами
    geonkick                                                      # Синтезатор барабанов
      # --- Гитарные процессоры и усилители ---
    lucerno-packages.amp-locker                                   # Плагин, эмулирующий стек гитарного тракта Amp-Locker
    fretboard                                                     # Гитарный гриф (примеры построения аккордов)
    lingot                                                        # Гитарный тюнер
      # --- Секвенсоры и генераторы ---
    stochas                                                       # Мощный вероятностный секвенсор (VST3/CLAP)
    lucerno-packages.music-pattern-generator                      # Music Pattern Generator – визуальный MIDI-секвенсор (NW.js)
      # --- Эффекты (обработка звука) ---
    lsp-plugins                                                   # Набор LSP: EQ, компрессоры, лимитеры, meters
    x42-plugins                                                   # Meters, EQ, компрессоры и другие LV2-плагины от Robin Gareus (Ardour dev)
    lucerno-packages.relic-clap                                   # Relic Free Audio Plugin Suite (компрессоры и прочее для сведения и мастеринга)
    lucerno-packages.air-g-plugins                                # Коллекция VST3-плагинов на основе Airwindows для микширования и мастеринга + педали еще туда засунул
    dragonfly-reverb                                              # Реверберация Dragonfly (VST/LV2)
    lucerno-packages.tape-echo-2                                  # Эмуляция Roland Space Echo (VST3 + CLAP + LV2)
    fire                                                          # Fire – многополосный плагин дисторшна с открытым исходным кодом от Wings Music (VST3)
    lucerno-packages.lostSamplers                                 # SuperflyDSP Lost Samplers – эмуляция шумов сэмплеров (VST3)
    lucerno-packages.lostTapes                                    # SuperflyDSP Lost Tapes – эмуляция магнитофона (VST3)
    lucerno-packages.lostVinyls                                   # SuperflyDSP Lost Vinyls – эмуляция винилового проигрывателя (VST3)
    lucerno-packages.pitchnet                                     # Нейросетевой корректор высоты тона (только VST3, standalone не собираю)
    lucerno-packages.tal-vocoder-2                                # TAL-Vocoder-2 — винтажный вокодер (VST3 + CLAP)
    rnnoise-plugin                                                # Нейро шумодав для голоса Real-time
    lucerno-packages.mulhacen-clap                                # Mulhacen — пятиполосный сустейнер от Node97 Audio с NAM + IR (CLAP) Альтернатива плагину Parallax
    lucerno-packages.satordist2                                   # SATORDIST2 — 4-полосный сатуратор (CLAP + VST3)

    ] ++ (with pkgs-unstable; [                                   # Пакеты из нестабильного канала (более свежие версии)
    # МУЗЫКА
      # --- DAW и среда ---
    reaper-sws-extension                                          # Расширение SWS для REAPER (дополнительные команды и автоматизация)
    reaper-reapack-extension                                      # Менеджер скриптов ReaPack для REAPER (установка пользовательских скриптов)
      # --- Гитарные процессоры и усилители ---
    ratatouille-lv2                                               # плагин для загрузки и микширования нейросетевых моделей гитарных усилителей (аналог Neural Amp Model)
      # --- Эффекты (обработка звука) ---
    noise-repellent                                               # Шумодав для пост обработки голоса (spectral subtraction, вносит задержку ~23 мс)
    zlequalizer                                                   # ZL Equalizer – 16-полосный динамический эквалайзер с поддержкой Mid/Side и режима Dynamic
    zlspectrumequalizer                                           # ZL Spectrum Analyzer – анализатор спектра в реальном времени с настраиваемым разрешением и режимом сравнения
    zlcompressor                                                  # ZL Compressor – компрессор с несколькими режимами (VCA/FET/OPT), sidechain и Mid/Side обработкой
    zlsplitter                                                    # ZL Splitter – частотный сплиттер для многополосной обработки (2–4 полосы с настраиваемыми кроссоверами)

    # KDE приложения
    kdePackages.kdenlive                                          # Видеоредактор (пока тут, т.к. в нестабильном 26.08 уже можно перемещать дорожки)
  ]);

}

# ===== Быстрый запуск утилит без установки (через nix run) =====
#nix run nixpkgs#lm-sensors                                                 # Утилита для отображения температуры и состояния датчиков оборудования
#nix run nixpkgs#genact                                                     # Генератор бессмысленной активности в терминале (имитация работы, для прикола)

# ===== Генерация конфигов Plasma Manager =====
#nix run github:nix-community/plasma-manager/trunk#rc2nix > plasma.nix      # Сгенерировать текущий конфиг Plasma в Nix-формате (rc2nix)
#nix run github:nix-community/plasma-manager#rc2nix > plasma-current.nix    # Альтернативный способ (из главной ветки) получить Nix-конфиг Plasma
