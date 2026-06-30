# modules/packages.nix
{ pkgs, pkgs-unstable, myLib, blender-cuda ? null }:

let
  optionalPackage = pkg: if pkg != null then [ pkg ] else [ ];  # Вспомогательная функция: добавляет пакет в список, только если он не null

  # ========== Дополнительные системные пакеты ==========
    # ./nixos/nx_obs.nix
    # ./nixos/nx_steam.nix

  systemPackages = with pkgs; [

    # СИСТЕМНЫЕ
    optinix                                                     # Инструмент для поиска опций в Nix
    nix-tree                                                    # Просмотр дерева зависимостей Nix
    home-manager                                                # Управление пользовательским окружением (конфиги, пакеты, службы)
    nil                                                         # LSP-сервер для Nix
    nix-du                                                      # Анализирует использование дискового пространства в Nix store
    nix-output-monitor                                          # Отслеживает сборку Nix и показывает прогресс зависимостей
    nix-index                                                   # Содержит nix-locate — утилиту для поиска файлов в Nix store (аналог locate, но для всех пакетов в store)
    cachix                                                      # Утилита для работы с кэшем Nix (добавление/управление бинарными кэшами)
    any-nix-shell                                               # Позволяет использовать Nix-оболочки из любого терминала. Упрощает работу с временными окружениями
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

    # ========== КОНСОЛЬНЫЕ УТИЛИТЫ ==========
    kitty                                                       # Эмулятор терминала с поддержкой GPU и лигатур
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
    fastfetch                                                   # Вывод информации о системе (красиво, быстро, замена neofetch)
    lsof                                                        # Просмотр открытых файлов и сокетов
    lnav                                                        # Просмотр лог-файлов с подсветкой и навигацией
    # carbonyl                                                  # (опционально) Консольный браузер на движке Chromium
    nvtopPackages.nvidia                                        # Монитор GPU NVIDIA в консоли (аналог htop для видеокарты)
    my-packages.btop                                            # Монитор ресурсов с графиками (аналог htop, но красивее)
    termshark                                                   # Анализатор сетевого трафика в терминале (альтернатива Wireshark)
    curl                                                        # Передача данных по сети (HTTP, FTP и т.д.)
    duf                                                         # Просмотр использования дискового пространства (удобная альтернатива df)
    dust                                                        # Анализ размера папок/файлов с визуализацией (аналог du, но нагляднее)
    ncdu                                                        # Интерактивный анализатор дискового пространства в стиле ncurses
    cava                                                        # Консольный аудиовизуализатор (спектроанализатор для музыки)
    neo                                                         # Матричный дождь из символов (эффект из фильма)

    # KDE приложения
    kdePackages.kcalc                                           # Калькулятор
    kdePackages.ktorrent                                        # Torrent-клиент
    kdePackages.kdenlive                                        # Видеоредактор
    (tesseract.override { enableLanguages = [ "eng" "rus" ]; }) # Tesseract — движок оптического распознавания символов (OCR) + Добавляет языковые пакеты: английский и русский

    # ИНТЕРНЕТ
    iw                                                          # Утилита для настройки беспроводных сетей (Wi-Fi)
    rclone                                                      # Утилита для синхронизации и монтирования облачных хранилищ (Google Drive, OneDrive и др.)
    wget                                                        # Утилита для загрузки файлов из интернета
    fail2ban
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
    blender-cuda.packages.${pkgs.stdenv.hostPlatform.system}.blender-with-cuda  # 3D-моделирование

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

  ]) ++ (optionalPackage (if blender-cuda != null then blender-cuda.packages.${pkgs.stdenv.hostPlatform.system}.blender-with-cuda else null));

  # ========== Пакеты, устанавливаемые через Home Manager ==========
  homePackages = with pkgs; [
    # тема для Oh My Zsh
    zsh-powerlevel10k                                           # Тема для Zsh с красивым информативным промптом (Powerlevel10k)

    # ИИ
    comfy-ui-cuda                                               # ComfyUI с поддержкой CUDA для генерации изображений через нейросети

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

in

{
  inherit systemPackages homePackages;

  # ========== Системные модули (только для NixOS) ==========
  nixosModule = { config, pkgs, lib, ... }: {

    programs.git.enable = true;                                 # Включает поддержку Git (утилита системы контроля версий)
    programs.dconf.enable = true;                               # Включает dconf – базу данных настроек для GTK-приложений (необходим для тем, шрифтов и т.п.)
    programs.zsh.enable = true;                                 # Регистрирует Zsh как системную оболочку
    programs.vim.enable = true;                                 # Устанавливает Vim (текстовый редактор) системно
    programs.nano.enable = true;                                # Устанавливает Nano (простой текстовый редактор) системно
    programs.htop.enable = true;                                # Устанавливает htop (интерактивный монитор процессов) системно
    programs.amnezia-vpn.enable = true;                         # Включает сервис AmneziaVPN (VPN-клиент)
    programs.appimage = {
      enable = true;                                            # Включает поддержку запуска AppImage-файлов (бинарные образы приложений)
      binfmt = true;                                            # Эта опция автоматически настраивает загрузчик
    };
    programs.nh = {                                             # Утилита для управления Nix
      enable = true;                                            # Включает утилиту nh (Nix Helper) для удобного управления системой и home-менеджером
      flake = "${myLib.home}/${myLib.configDirName}";           # Указывает путь к flake, содержащему конфигурации NixOS и home-manager
    };
    # KDE приложения
    programs.partition-manager.enable = true;                   # Включает модуль для утилиты управления разделами диска (KDE Partition Manager)
    programs.kdeconnect.enable = true;                          # Включает интеграцию с телефоном: синхронизация уведомлений, буфера обмена, управление презентациями и т.д.


    environment.systemPackages = systemPackages;                # Используем уже определённый список systemPackages
  };
}

# ===== Быстрый запуск утилит без установки (через nix run) =====
#nix run nixpkgs#lm-sensors                                                 # Утилита для отображения температуры и состояния датчиков оборудования
#nix run nixpkgs#genact                                                     # Генератор бессмысленной активности в терминале (имитация работы, для прикола)

# ===== Настройка Plasma Manager (генерация конфигов) =====
#nix run github:nix-community/plasma-manager/trunk#rc2nix > plasma.nix      # Сгенерировать текущий конфиг Plasma в Nix-формате (rc2nix)
#nix run github:nix-community/plasma-manager#rc2nix > plasma-current.nix    # Альтернативный способ (из главной ветки) получить Nix-конфиг Plasma
