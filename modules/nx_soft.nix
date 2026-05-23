# modules/nx_soft.nix
{ config, pkgs, pkgs-unstable, ... }:

{
  imports = [
    ./nx_steam.nix
    ./nx_obs.nix
    #./nx_thunar.nix
  ];

  # ========== Включение системных модулей для программ ==========
  programs.git.enable = true;                           # Включает поддержку Git (утилита системы контроля версий)
  programs.dconf.enable = true;                         # Включает dconf – базу данных настроек для GTK-приложений (необходим для тем, шрифтов и т.п.)
  programs.zsh.enable = true;                           # Регистрирует Zsh как системную оболочку
  programs.vim.enable = true;                           # Устанавливает Vim (текстовый редактор) системно
  programs.nano.enable = true;                          # Устанавливает Nano (простой текстовый редактор) системно
  programs.htop.enable = true;                          # Устанавливает htop (интерактивный монитор процессов) системно
  programs.amnezia-vpn.enable = true;                   # Включает сервис AmneziaVPN (VPN-клиент)
  programs.appimage = {
    enable = true;
    binfmt = true; # Эта опция автоматически настраивает загрузчик.
  };
  # KDE приложения
  programs.partition-manager.enable = true;             # Включает модуль для утилиты управления разделами диска (KDE Partition Manager)

  # ========== Дополнительные системные пакеты ==========
  environment.systemPackages = with pkgs; [
    nh                                                  # Утилита для удобного управления Nix (аналог nix-env, nix profile)
    nix-tree                                            # Просмотр дерева зависимостей Nix
    home-manager                                        # Управление пользовательским окружением (конфиги, пакеты, службы)
    iw                                                  # Утилита для настройки беспроводных сетей (Wi-Fi)
    wirelesstools                                       # Набор инструментов для работы с Wi-Fi (iwconfig, iwlist и др.)
    base16-schemes
    curl                                                # Инструмент для передачи данных по сети (HTTP, FTP и др.)
    uv                                                  # Менеджер Python-проектов (альтернатива pip + virtualenv)
    gsettings-desktop-schemas                           # Схемы настроек для GSettings (используются GTK-приложениями)
    lsof                                                # Просмотр открытых файлов и сокетов
    kitty                                               # Терминал с поддержкой GPU, вкладок и широкими возможностями кастомизации
    lf                                                  # Быстрый файловый менеджер на Go с vim-подобным управлением
    mc                                                  # Midnight Commander – классический двухпанельный файловый менеджер (FTP, просмотр, редактор)
    yazi                                                # Современный файловый менеджер на Rust с предпросмотром изображений и видео
    unzip                                               # Утилита для распаковки ZIP-архивов
    wget                                                # Утилита для загрузки файлов из интернета
    fastfetch                                           # Вывод информации о системе (аналог neofetch, но быстрее)
    # carbonyl                                          # Консольный браузер на движке Chromium (закомментирован)
    nvtopPackages.nvidia                                # Монитор использования видеокарты NVIDIA в консоли (nvtop)
    wayland-utils                                       # Набор утилит для диагностики Wayland (например, wayland-info)
    glib                                                # Базовая библиотека GLib (низкоуровневые структуры данных)
    libva-utils                                         # Утилиты для VA-API (аппаратное ускорение видео)
    my-packages.btop                                    # Монитор ресурсов с графическим интерфейсом в терминале (аналог htop)
    bat                                                 # Улучшенный аналог cat с подсветкой синтаксиса
    mission-center                                      # Графический монитор системы (альтернатива btop)
    gearlever                                           # Менеджер обновлений для графических приложений (например, Flatpak)

    # KDE приложения
    kdePackages.ktorrent                                # Torrent-клиент
    kdePackages.kdenlive                                # Видеоредактор
    kdePackages.kcalc                                   # Калькулятор

    # ИНТЕРНЕТ
    google-chrome                                       # Браузер Google Chrome
    parabolic                                           # Загрузчик видео/аудио с YouTube (альтернатива yt-dlp)
    discord                                             # Голосовой/текстовый чат
    telegram-desktop                                    # Мессенджер Telegram

    # ГРАФИКА
    switcheroo
    pinta                                               # Простой растровый редактор
    gimp                                                # Мощный растровый редактор
    inkscape                                            # Векторная графика
    blender                                             # 3D-моделирование
    upscaler                                            # Увеличение разрешения изображений
    krita                                               # Кастомный пакет Krita (цифровая живопись)

    # МУЛЬТИМЕДИА
    my-packages.qmmp                                    # Аудиоплеер с поддержкой множества форматов
    deadbeef                                            # Аудиоплеер с низким потреблением ресурсов
    vlc                                                 # Универсальный видеоплеер
    cava

    # ИГРЫ
    my-packages.minion                                  # Менеджер аддонов для TESO
    (bottles.override { removeWarningPopup = true; })   # Запуск Windows-приложений через Wine (без всплывающих предупреждений)
    lutris                                              # Игровой лаунчер для управления играми
    heroic                                              # Лаунчер для Epic Games Store и GOG
    goverlay                                            # Оверлей для мониторинга системы и FPS (MangoHud, vkBasalt)
    mangohud                                            # Оверлей для отображения FPS и мониторинга системы в играх

    # МУЗЫКА
    my-packages.reaper                                  # REAPER – цифровая звуковая рабочая станция (DAW) БЕРЕТСЯ ИЗ НЕСТАБИЛЬНОГО КАНАЛА!!!!
    yabridge                                            # Мост для запуска Windows VST-плагинов в Linux (через Wine)
    yabridgectl                                         # Утилита для управления yabridge (сканирование, синхронизация)
    winetricks                                          # Вспомогательный скрипт для настройки Wine (установка DLL, зависимостей)
    coppwr                                              # Графическая утилита для управления PipeWire (альтернатива pw-top)
    vital                                               # Популярный синтезатор FM (VST-плагин)
    surge-xt                                            # Синтезатор Surge XT
    geonkick                                            # Синтезатор барабанов для создания ударных партий
    drumgizmo                                           # Многоканальный сэмплер барабанов (реалистичные ударные)
    neural-amp-modeler-lv2                              # Плагин LV2 для моделирования гитарных усилителей (Neural Amp Modeler)
    dragonfly-reverb                                    # Качественная реверберация Dragonfly (VST/LV2)
    fretboard                                           # Гитаровый гриф / MIDI-инструмент (возможно, для обучения)

  ] ++ (with pkgs-unstable; [                           # Пакеты из нестабильного канала (более свежие версии)
    # МУЗЫКА
    wineWow64Packages.staging                           # Wine с поддержкой 64 и 32 бит (staging‑патчи для аудио)
    reaper-sws-extension                                # Расширение SWS для REAPER (дополнительные команды и автоматизация)
    reaper-reapack-extension                            # Менеджер скриптов ReaPack для REAPER (установка пользовательских скриптов)
  ]);

#nix run nixpkgs#genact
#nix run nixpkgs#cmatrix
#nix run nixpkgs#caligula
#настройки плазма менеджера
#nix run github:nix-community/plasma-manager/trunk#rc2nix > plasma.nix
#nix run github:nix-community/plasma-manager#rc2nix > plasma-current.nix

}
