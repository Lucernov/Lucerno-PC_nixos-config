# modules/packages.nix
{ pkgs, pkgs-unstable }:
  # ========== Включение системных модулей для программ ==========
    # ./nixos/nx_packages_system_modules.nix -> git dconf zsh vim nano htop amnezia appimage partition-manager kdeconnect

  # ========== Дополнительные системные пакеты ==========
    # ./nixos/nx_obs.nix
    # ./nixos/nx_steam.nix
{
  systemPackages = with pkgs; [

    # СИСТЕМНЫЕ
    nh                                                          # Утилита для управления Nix
    optinix                                                     # Инструмент для поиска опций в Nix
    nix-tree                                                    # Просмотр дерева зависимостей Nix
    home-manager                                                # Управление пользовательским окружением (конфиги, пакеты, службы)
    nil                                                         # LSP-сервер для Nix
    glib                                                        # Базовая библиотека GLib (низкоуровневые структуры данных)
    openh264                                                    # Кодек H.264 от Cisco с открытым исходным кодом. Используется для аппаратного кодирования
    uv                                                          # Менеджер Python-проектов (альтернатива pip + virtualenv)
    gsettings-desktop-schemas                                   # Схемы настроек для GSettings (используются GTK-приложениями)
    ffmpeg-full                                                 # Полная версия FFmpeg (кодирование/декодирование аудио/видео)
    base16-schemes                                              # Набор цветовых схем Base16 (для терминалов, редакторов)
    libva-utils                                                 # Утилиты для VA-API (аппаратное ускорение видео)
    wayland-utils                                               # Набор утилит для диагностики Wayland (например, wayland-info)
    gearlever                                                   # Менеджер обновлений для графических приложений (например, AppImages)
    mission-center                                              # Графический монитор системы (альтернатива btop)

    # КОНСОЛЬНЫЕ
    kitty                                                       # Эмулятор терминала
    mc                                                          # Midnight Commander – классический двухпанельный файловый менеджер (FTP, просмотр, редактор)
    yazi                                                        # Современный файловый менеджер на Rust с предпросмотром изображений и видео
    unzip                                                       # Утилита для распаковки ZIP-архивов
    rar                                                         # Архиватор для работы с форматом RAR (сжатие и распаковка)
    fastfetch                                                   # Вывод информации о системе (аналог neofetch, но быстрее)
    lsof                                                        # Просмотр открытых файлов и сокетов
    lnav                                                        # Просмотр и анализ лог-файлов с подсветкой синтаксиса и удобной навигацией
    # carbonyl                                                  # Консольный браузер на движке Chromium
    nvtopPackages.nvidia                                        # Монитор использования видеокарты NVIDIA в консоли (nvtop)
    my-packages.btop                                            # Монитор ресурсов с графическим интерфейсом в терминале (аналог htop)
    bat                                                         # Улучшенный аналог cat с подсветкой синтаксиса
    termshark                                                   # Консольный интерфейс для анализа сетевых пакетов (аналог Wireshark в терминале)
    curl                                                        # Инструмент для передачи данных по сети (HTTP, FTP и др.)
    duf                                                         # Утилита для просмотра использования дискового пространства (более удобный аналог df)
    dust                                                        # Быстрая утилита для анализа размера папок и файлов (аналог du, но с графиками)
    ncdu                                                        # Интерактивный анализатор дискового пространства с интерфейсом ncurses
    cava                                                        # Консольный аудиовизуализатор (спектроанализатор)
    neo                                                         # Знаменитый "Матричный" дождь из символов (эффект из фильма)

    # KDE приложения
    kdePackages.kcalc                                           # Калькулятор
    kdePackages.ktorrent                                        # Torrent-клиент
    kdePackages.kdenlive                                        # Видеоредактор
    (tesseract.override { enableLanguages = [ "eng" "rus" ]; }) # Tesseract — движок оптического распознавания символов (OCR) + Добавляет языковые пакеты: английский и русский

    # ИНТЕРНЕТ
    iw                                                          # Утилита для настройки беспроводных сетей (Wi-Fi)
    rclone                                                      # Утилита для синхронизации и монтирования облачных хранилищ (Google Drive, OneDrive и др.)
    wget                                                        # Утилита для загрузки файлов из интернета
    authenticator                                               # Приложение для двухфакторной аутентификации (TOTP, HOTP), например, для аккаунтов Google, GitHub и т.д.
    google-chrome                                               # Браузер Google Chrome
    parabolic                                                   # Загрузчик видео/аудио с YouTube (альтернатива yt-dlp)
    (discord.override { withOpenASAR = true; })                 # Голосовой/текстовый чат
    telegram-desktop                                            # Мессенджер Telegram

    # ГРАФИКА
    upscaler                                                    # Увеличение разрешения изображений
    switcheroo                                                  # приложение для конвертации изображений
    optipng                                                     # Оптимизатор PNG файлов
    pinta                                                       # Простой растровый редактор
    krita                                                       # Кастомный пакет Krita (цифровая живопись)
    inkscape                                                    # Векторная графика
    (blender.override { cudaSupport = true; })                  # 3D-моделирование

    # МУЛЬТИМЕДИА
    my-packages.qmmp                                            # Аудиоплеер
    vlc                                                         # Универсальный видеоплеер

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
    retroarch                                                   # Эмулятор приставок
    #lutris                                                     # Игровой лаунчер для управления играми
    #heroic                                                     # Лаунчер для Epic Games Store и GOG

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
  homePackages = with pkgs; [

    # ИИ
    comfy-ui-cuda

    # --- Ретро-ядра для RetroArch ---
    libretro.mesen                                              # Nintendo NES
    libretro.bsnes                                              # Nintendo SNES
    libretro.parallel-n64                                       # Nintendo 64 (Vulkan)
    libretro.genesis-plus-gx                                    # Sega Genesis / Mega Drive (плюс Master System, Game Gear, Sega CD)
    libretro.beetle-saturn                                      # Sega Saturn
    libretro.flycast                                            # Sega Dreamcast
    libretro.ppsspp                                             # PSP
    libretro.beetle-psx-hw                                      # PlayStation 1
    libretro.pcsx2                                              # PlayStation 2

  ] ++ (with pkgs-unstable; [ ]);


# ===== Быстрый запуск утилит без установки (через nix run) =====
#nix run nixpkgs#lm-sensors                                                 # Утилита для отображения температуры и состояния датчиков оборудования
#nix run nixpkgs#genact                                                     # Генератор бессмысленной активности в терминале (имитация работы, для прикола)

# ===== Настройка Plasma Manager (генерация конфигов) =====
#nix run github:nix-community/plasma-manager/trunk#rc2nix > plasma.nix      # Сгенерировать текущий конфиг Plasma в Nix-формате (rc2nix)
#nix run github:nix-community/plasma-manager#rc2nix > plasma-current.nix    # Альтернативный способ (из главной ветки) получить Nix-конфиг Plasma
}
