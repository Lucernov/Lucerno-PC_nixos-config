# modules/packages.nix
{ pkgs, pkgs-unstable, myLib, blender-cuda ? null }:

let
  # ========== Дополнительные системные пакеты ==========
    # ./nixos/nx_obs.nix
    # ./nixos/nx_steam.nix

  systemPackages = with pkgs; [
    # СИСТЕМНЫЕ
    manix                                                       # Универсальный поиск по документации Nix
    nix-tree                                                    # Просмотр дерева зависимостей Nix
    home-manager                                                # Управление пользовательским окружением (конфиги, пакеты, службы)
    nil                                                         # LSP-сервер для Nix
    nix-du                                                      # Анализирует использование дискового пространства в Nix store
    nix-output-monitor                                          # Отслеживает сборку Nix и показывает прогресс зависимостей
    cachix                                                      # Утилита для работы с кэшем Nix (добавление/управление бинарными кэшами)
    any-nix-shell                                               # Позволяет использовать Nix-оболочки из любого терминала. Упрощает работу с временными окружениями
    nixpkgs-fmt                                                 # Форматтер Nix (автоматическое форматирование кода)
    statix                                                      # Линтер Nix (статический анализ)
    deadnix                                                     # Поиск мёртвого (неиспользуемого) кода в Nix
    openh264                                                    # Кодек H.264 от Cisco с открытым исходным кодом. Используется для аппаратного кодирования
    uv                                                          # Менеджер Python-проектов (альтернатива pip + virtualenv)
    gsettings-desktop-schemas                                   # Схемы настроек для GSettings (используются GTK-приложениями)
    ffmpeg-full                                                 # Полная версия FFmpeg (кодирование/декодирование аудио/видео)
    base16-schemes                                              # Набор цветовых схем Base16 (для терминалов, редакторов)
    libva-utils                                                 # Утилиты для VA-API (аппаратное ускорение видео)
    wayland-utils                                               # Набор утилит для диагностики Wayland (например, wayland-info)
    gearlever                                                   # Менеджер обновлений для графических приложений (например, AppImages)
    mission-center                                              # Графический монитор системы (альтернатива btop)
    lact                                                        # Утилита для управления видеокартами NVIDIA и AMD (мониторинг, разгон, управление вентиляторами, настройка VF-кривой). Для NVIDIA требуется библиотека NVML
    strace                                                      # перехватывает и записывает все системные вызовы (поиск ошибок запуска программ)
    usbutils                                                    # Набор утилит для работы с USB (lsusb, usb-devices, диагностика USB-устройств)
    alsa-utils                                                  # Утилиты для работы с ALSA (aplay, arecord, alsamixer, управление звуковыми картами)

    # ========== КОНСОЛЬНЫЕ УТИЛИТЫ ==========
    kitty                                                       # Эмулятор терминала с поддержкой GPU и лигатур
    zsh-powerlevel10k                                           # Тема для Zsh с красивым информативным промптом (Powerlevel10k)
    lsd                                                         # Улучшенный аналог ls с иконками и цветами
    bat                                                         # Улучшенный cat с подсветкой синтаксиса и интеграцией с Git
    zoxide                                                      # Умная замена cd, запоминающая часто используемые папки
    fd                                                          # Простая и быстрая альтернатива find
    ripgrep                                                     # Очень быстрый grep для поиска по коду
    fzf                                                         # Интерактивный фильтр для командной строки (поиск)
    tree                                                        # Показывает дерево каталогов
    lazygit                                                     # TUI-интерфейс для Git (удобное управление репозиториями)
    mc                                                          # Midnight Commander – классический двухпанельный файловый менеджер
    yazi                                                        # Современный файловый менеджер на Rust с предпросмотром изображений и видео
    unzip                                                       # Распаковка ZIP-архивов
    rar                                                         # Работа с архивами RAR (сжатие и распаковка)
    fastfetch                                                   # Вывод информации о системе
    lsof                                                        # Просмотр открытых файлов и сокетов
    lnav                                                        # Просмотр лог-файлов с подсветкой и навигацией
    # carbonyl                                                  # Консольный браузер на движке Chromium
    nvtopPackages.nvidia                                        # Монитор GPU NVIDIA в консоли (аналог htop для видеокарты)
    my-packages.btop                                            # Монитор ресурсов с графиками (аналог htop, но красивее)
    termshark                                                   # Анализатор сетевого трафика в терминале (альтернатива Wireshark)
    duf                                                         # Просмотр использования дискового пространства (удобная альтернатива df)
    dust                                                        # Анализ размера папок/файлов с визуализацией (аналог du, но нагляднее)
    cava                                                        # Консольный аудиовизуализатор (спектроанализатор для музыки)
    neo                                                         # Матричный дождь из символов (эффект из фильма)

    # KDE приложения
    kdePackages.kcalc                                           # Калькулятор
    kdePackages.ktorrent                                        # Torrent-клиент
    kdePackages.kdenlive                                        # Видеоредактор
    (tesseract.override { enableLanguages = [ "eng" "rus" ]; }) # Tesseract — движок оптического распознавания символов (OCR) + Добавляет языковые пакеты: английский и русский

    # ИНТЕРНЕТ
    iw                                                          # Утилита для настройки беспроводных сетей (Wi-Fi)
    fail2ban                                                    # Демон для блокировки подозрительных IP-адресов (защита от брутфорса)
    rclone                                                      # Утилита для синхронизации и монтирования облачных хранилищ (Google Drive, OneDrive и др.)
    wget                                                        # Утилита для загрузки файлов из интернета
    authenticator                                               # Приложение для двухфакторной аутентификации (TOTP, HOTP), например, для аккаунтов Google, GitHub и т.д.
    google-chrome                                               # Браузер Google Chrome
    parabolic                                                   # Загрузчик видео/аудио с YouTube (альтернатива yt-dlp)
    (discord.override { withOpenASAR = true; })                 # Голосовой/текстовый чат
    vesktop
    telegram-desktop                                            # Мессенджер Telegram

    # ГРАФИКА
    upscaler                                                    # Увеличение разрешения изображений
    switcheroo                                                  # приложение для конвертации изображений
    optipng                                                     # Оптимизатор PNG файлов
    pinta                                                       # Простой растровый редактор
    krita                                                       # Кастомный пакет Krita (цифровая живопись)
    inkscape                                                    # Векторная графика

    # 3D-моделирование
    blender-cuda.packages.${pkgs.stdenv.hostPlatform.system}.blender-with-cuda  # 3D редактор
    freecad                                                     # Уже нормальный 3D кад
    prusa-slicer                                                # Слайсер для 3D принтера
    printrun                                                    # Соединение с 3D принтером и отправка на печать по usb

    # МУЛЬТИМЕДИА
    my-packages.qmmp                                            # Аудиоплеер
    vlc                                                         # Универсальный видеоплеер
    mpv                                                         # Видеоплеер (корректно открывает AV1)

    # ОФИС
    eloquent                                                    # Проверка орфографии и стилистики текста (аналог LanguageTool)
    planify                                                     # Менеджер задач и проектов (GTK, синхронизация с Todoist, Nextcloud)
    libreoffice-qt-still                                        # Офисный пакет LibreOffice (стабильная ветка) с интеграцией в KDE Plasma через Qt
    hunspellDicts.ru_RU                                         # Словарь для проверки орфографии (русский язык)
    hyphenDicts.ru_RU                                           # Словарь для автоматической расстановки переносов (русский язык)
    papers                                                      # Просмотрщик документов (PDF, DjVu, PostScript) — современная альтернатива Evince для GNOME

    # ИГРЫ
    my-packages.minion                                          # Менеджер аддонов для TESO
    (bottles.override { removeWarningPopup = true; })           # Запуск Windows-приложений через Wine (без всплывающих предупреждений)
    goverlay                                                    # Оверлей для мониторинга системы и FPS (MangoHud, vkBasalt)
    mangohud                                                    # Оверлей для отображения FPS и мониторинга системы в играх
    (retroarch.withCores (cores: with cores; [                  # Эмулятор приставок
      mesen                                                     # Ядро Nintendo NES
      bsnes                                                     # Ядро Nintendo SNES
      parallel-n64                                              # Ядро Nintendo 64 (Vulkan)
      genesis-plus-gx                                           # Ядро Sega Genesis / Mega Drive (плюс Master System, Game Gear, Sega CD)
      beetle-saturn                                             # Ядро Sega Saturn
      flycast                                                   # Ядро Sega Dreamcast
      ppsspp                                                    # Ядро PSP
      beetle-psx-hw                                             # Ядро PlayStation 1
      pcsx2                                                     # Ядро PlayStation 2
    ]))
    #lutris                                                     # Игровой лаунчер для управления играми
    #heroic                                                     # Лаунчер для Epic Games Store и GOG

    # ИИ
    comfy-ui-cuda                                               # ComfyUI с поддержкой CUDA для генерации изображений через нейросети

    # МУЗЫКА
    my-packages.reaper                                          # REAPER – цифровая звуковая рабочая станция (DAW) БЕРЕТСЯ ИЗ НЕСТАБИЛЬНОГО КАНАЛА!!!!
    wineWow64Packages.staging                                   # Wine с поддержкой 64 и 32 бит (staging‑патчи для аудио)
    yabridge                                                    # Мост для запуска Windows VST-плагинов в Linux (через Wine)
    yabridgectl                                                 # Утилита для управления yabridge (сканирование, синхронизация)
    winetricks                                                  # Вспомогательный скрипт для настройки Wine (установка DLL, зависимостей)
    coppwr                                                      # Графическая утилита для управления PipeWire (альтернатива pw-top)
    vital                                                       # Синтезатор FM (VST-плагин)
    surge-xt                                                    # Синтезатор Surge XT
    geonkick                                                    # Синтезатор барабанов для создания ударных партий
    drumgizmo                                                   # Многоканальный сэмплер барабанов (реалистичные ударные)
    decent-sampler                                              # Сэмплер для библиотек DecentSampler (формат .dspreset, .dslibrary)
    linuxsampler                                                # Движок-семплер (без графического интерфейса), поддерживает форматы GIG, SFZ и SF2. Управление через внешние фронтенды (qsampler, carla) по протоколу LSCP
    qsampler                                                    # Графический интерфейс (Qt) для управления LinuxSampler: загрузка инструментов, настройки, просмотр состояния
    fluida-lv2                                                  # LV2-обёртка вокруг FluidSynth. Позволяет использовать FluidSynth как LV2-плагин в DAW для воспроизведения SoundFont (SF2/SF3)
    dragonfly-reverb                                            # Реверберация Dragonfly (VST/LV2)
    calf                                                        # Calf Studio Gear один из самых известных и полных наборов аудио-плагинов для Linux
    fretboard                                                   # Гитаровый гриф / MIDI-инструмент
    lingot                                                      # гитарный тюнер
    neural-amp-modeler-lv2                                      # Плагин LV2 для моделирования гитарных усилителей (Neural Amp Modeler)
    guitarix                                                    # виртуальная гитарная станция с эффектами, усилителями, кабинетами и поддержкой NAM-моделей
    guitarix-vst                                                # экспорт движка Guitarix в виде VST3-плагина для использования внутри DAW
    gxplugins-lv2                                               # набор дополнительных LV2-плагинов от разработчиков Guitarix

  ] ++ (with pkgs-unstable; [                                   # Пакеты из нестабильного канала (более свежие версии)
    # МУЗЫКА
    reaper-sws-extension                                        # Расширение SWS для REAPER (дополнительные команды и автоматизация)
    reaper-reapack-extension                                    # Менеджер скриптов ReaPack для REAPER (установка пользовательских скриптов)
    lsp-plugins                                                 # Набор VST/LV2-плагинов для обработки звука (LSP)

  ]);

  # ========== Пакеты, устанавливаемые через Home Manager ==========
  homePackages = with pkgs; [ ] ++ (with pkgs-unstable; [ ]);

in

{
  inherit systemPackages homePackages;

  # ========== Системные модули (только для NixOS) ==========
  nixosModule = { config, pkgs, lib, myLib, ... }: {
    programs = {
      git.enable = true;                                        # Включает поддержку Git
      nix-index.enable = true;                                  # Автоматически обновлять индекс для nix-locate при каждом переключении поколения
      dconf.enable = true;                                      # Включает dconf – базу данных настроек для GTK-приложений
      zsh.enable = true;                                        # Регистрирует Zsh как системную оболочку
      vim.enable = true;                                        # Устанавливает Vim (текстовый редактор) системно
      nano.enable = true;                                       # Устанавливает Nano (простой текстовый редактор) системно
      htop.enable = true;                                       # Устанавливает htop (интерактивный монитор процессов) системно
      amnezia-vpn.enable = true;                                # Включает сервис AmneziaVPN (VPN-клиент)
      appimage = {
        enable = true;                                          # Включает поддержку запуска AppImage-файлов
        binfmt = true;                                          # Автоматически настраивает загрузчик
      };
      nh = {
        enable = true;                                          # Включает утилиту nh (Nix Helper)
        flake = "${myLib.home}/${myLib.configDirName}";         # Указывает путь к flake
      };
      # KDE приложения
      partition-manager.enable = true;                          # Включает модуль для KDE Partition Manager
      kdeconnect.enable = true;                                 # Включает интеграцию с телефоном через KDE Connect
    };

    environment.systemPackages = systemPackages;                # Используем уже определённый список systemPackages
  };
}

# ===== Быстрый запуск утилит без установки (через nix run) =====
#nix run nixpkgs#lm-sensors                                                 # Утилита для отображения температуры и состояния датчиков оборудования
#nix run nixpkgs#genact                                                     # Генератор бессмысленной активности в терминале (имитация работы, для прикола)

# ===== Настройка Plasma Manager (генерация конфигов) =====
#nix run github:nix-community/plasma-manager/trunk#rc2nix > plasma.nix      # Сгенерировать текущий конфиг Plasma в Nix-формате (rc2nix)
#nix run github:nix-community/plasma-manager#rc2nix > plasma-current.nix    # Альтернативный способ (из главной ветки) получить Nix-конфиг Plasma
