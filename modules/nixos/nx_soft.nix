# modules/nx_soft.nix
{ config, pkgs, pkgs-unstable, ... }:

{

# nx_steam.nix
# nx_obs.nix

  # ========== Включение системных модулей для программ ==========
  programs.git.enable = true;                                   # Включает поддержку Git (утилита системы контроля версий)
  programs.dconf.enable = true;                                 # Включает dconf – базу данных настроек для GTK-приложений (необходим для тем, шрифтов и т.п.)
  programs.zsh.enable = true;                                   # Регистрирует Zsh как системную оболочку
  programs.vim.enable = true;                                   # Устанавливает Vim (текстовый редактор) системно
  programs.nano.enable = true;                                  # Устанавливает Nano (простой текстовый редактор) системно
  programs.htop.enable = true;                                  # Устанавливает htop (интерактивный монитор процессов) системно
  programs.amnezia-vpn.enable = true;                           # Включает сервис AmneziaVPN (VPN-клиент)
  programs.retroarch.enable = true;                             # Эмулятор приставок
  programs.appimage = {
    enable = true;                                              # Включает поддержку запуска AppImage-файлов (бинарные образы приложений)
    binfmt = true;                                              # Эта опция автоматически настраивает загрузчик.
  };
  # KDE приложения
  programs.partition-manager.enable = true;                     # Включает модуль для утилиты управления разделами диска (KDE Partition Manager)
  programs.kdeconnect.enable = true;                            # Включает интеграцию с телефоном: синхронизация уведомлений, буфера обмена, управление презентациями и т.д.

  # ========== Дополнительные системные пакеты ==========
  environment.systemPackages = with pkgs; [
    # СИСТЕМНЫЕ
    nh                                                          # Утилита для управления Nix
    optinix                                                     # Инструмент для поиска опций в Nix
    nix-tree                                                    # Просмотр дерева зависимостей Nix
    home-manager                                                # Управление пользовательским окружением (конфиги, пакеты, службы)
    glib                                                        # Базовая библиотека GLib (низкоуровневые структуры данных)
    uv                                                          # Менеджер Python-проектов (альтернатива pip + virtualenv)
    gsettings-desktop-schemas                                   # Схемы настроек для GSettings (используются GTK-приложениями)
    ffmpeg-full                                                 # Полная версия FFmpeg (кодирование/декодирование аудио/видео)
    base16-schemes                                              # Набор цветовых схем Base16 (для терминалов, редакторов)
    curl                                                        # Инструмент для передачи данных по сети (HTTP, FTP и др.)
    libva-utils                                                 # Утилиты для VA-API (аппаратное ускорение видео)
    lsof                                                        # Просмотр открытых файлов и сокетов
    wayland-utils                                               # Набор утилит для диагностики Wayland (например, wayland-info)
    gearlever                                                   # Менеджер обновлений для графических приложений (например, AppImages)
    rar                                                         # Архиватор для работы с форматом RAR (сжатие и распаковка)

    # КОНСОЛЬНЫЕ
    kitty                                                       # Эмулятор терминала
    mc                                                          # Midnight Commander – классический двухпанельный файловый менеджер (FTP, просмотр, редактор)
    yazi                                                        # Современный файловый менеджер на Rust с предпросмотром изображений и видео
    unzip                                                       # Утилита для распаковки ZIP-архивов
    fastfetch                                                   # Вывод информации о системе (аналог neofetch, но быстрее)
    # carbonyl                                                  # Консольный браузер на движке Chromium
    nvtopPackages.nvidia                                        # Монитор использования видеокарты NVIDIA в консоли (nvtop)
    my-packages.btop                                            # Монитор ресурсов с графическим интерфейсом в терминале (аналог htop)
    bat                                                         # Улучшенный аналог cat с подсветкой синтаксиса
    mission-center                                              # Графический монитор системы (альтернатива btop)
    cava                                                        # Консольный аудиовизуализатор (спектроанализатор)

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
    discord                                                     # Голосовой/текстовый чат
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
    #retroarch                                                   # Эмулятор приставок
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

    # ИИ
    comfy-ui-cuda

  ] ++ (with pkgs-unstable; [                                   # Пакеты из нестабильного канала (более свежие версии)
    # МУЗЫКА
    reaper-sws-extension                                        # Расширение SWS для REAPER (дополнительные команды и автоматизация)
    reaper-reapack-extension                                    # Менеджер скриптов ReaPack для REAPER (установка пользовательских скриптов)
    lsp-plugins                                                 # Набор VST/LV2-плагинов для обработки звука (LSP)
  ]);

#nix run nixpkgs#genact
#nix run nixpkgs#cmatrix
#nix run nixpkgs#caligula
#настройки плазма менеджера
#nix run github:nix-community/plasma-manager/trunk#rc2nix > plasma.nix
#nix run github:nix-community/plasma-manager#rc2nix > plasma-current.nix

}
