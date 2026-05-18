# modules/nx_soft.nix
{ config, pkgs, pkgs-unstable, ... }:

{
  imports = [
    ./nx_steam.nix
    ./nx_obs.nix
    ./nx_thunar.nix
  ];

  # ========== Включение системных модулей для программ ==========
  programs.git.enable = true;           # Включает поддержку Git (утилита системы контроля версий)
  programs.dconf.enable = true;         # Включает dconf – базу данных настроек для GTK-приложений (необходим для тем, шрифтов и т.п.)
  programs.zsh.enable = true;           # Регистрирует Zsh как системную оболочку
  programs.vim.enable = true;           # Устанавливает Vim (текстовый редактор) системно
  programs.nano.enable = true;          # Устанавливает Nano (простой текстовый редактор) системно
  programs.htop.enable = true;          # Устанавливает htop (интерактивный монитор процессов) системно
  programs.amnezia-vpn.enable = true;   # Включает сервис AmneziaVPN (VPN-клиент)
  # KDE приложения
  programs.partition-manager.enable = true;                 # Включает модуль для утилиты управления разделами диска (KDE Partition Manager)

  # ========== Дополнительные системные пакеты ==========
  environment.systemPackages = with pkgs; [
    nh                                      # Утилита для удобного управления Nix
    home-manager
    iw
    wirelesstools
    kitty
    lf                                      # "List Files" – быстрый файловый менеджер на Go с vim-подобным управлением
    mc                                      # Midnight Commander – классический двухпанельный файловый менеджер (FTP, просмотр, редактор)
    yazi
    unzip                                   # Утилита для распаковки ZIP-архивов
    curl                                    # Инструмент для передачи данных по сети (HTTP, FTP и др.)
    wget                                    # Утилита для загрузки файлов из интернета
    fastfetch                               # Вывод информации о системе (аналог neofetch)
    # carbonyl                              # Консольный браузер
    nvtopPackages.nvidia                    # Монитор использования видеокарты NVIDIA в консоли nvtop
    wayland-utils                           # Набор утилит для диагностики Wayland (например, wayland-info)
    gsettings-desktop-schemas               # Схемы настроек для GSettings (используются GTK-приложениями)
    glib                                    # Базовая библиотека GLib (низкоуровневые структуры данных)
    libva-utils                             # Утилиты для VA-API (аппаратное ускорение видео)
    (btop.override { withGPU = true; })     # Монитор ресурсов с графическим интерфейсом в терминале
    bat                                     # Улучшенный аналог cat с подсветкой синтаксиса
    mission-center                          # Графический монитор системы (альтернатива btop)
    nix-tree                                # Просмотр дерева зависимостей Nix

    gearlever

    lsof                                    # Просмотр открытых файлов и сокетов

    # KDE приложения (графические, не требующие системной интеграции)
    kdePackages.ktorrent                    # Torrent-клиент
    kdePackages.kdenlive                    # Видеоредактор
    kdePackages.kcalc                       # Калькулятор

    # ИНТЕРНЕТ
    google-chrome                           # Браузер Google Chrome
    parabolic                               # Загрузчик видео/аудио с YouTube (альтернатива yt-dlp)
    discord                                 # Голосовой/текстовый чат
    telegram-desktop                        # Мессенджер Telegram

    # ГРАФИКА
    pinta                                   # Простой растровый редактор
    krita                                   # Кастомный пакет Krita цифровая живопись – теперь берётся из оверлея
    gimp                                    # Мощный растровый редактор
    inkscape                                # Векторная графика
    blender                                 # 3D-моделирование
    upscaler                                # Увеличение разрешения изображений

    # МУЛЬТИМЕДИА
    my-packages.qmmp                        # Кастомный пакет qmmp – теперь берётся из оверлея
    vlc                                     # Универсальный видеоплеер
    deadbeef

    # ИГРЫ
    my-packages.minion                      # Кастомный пакет minion (обёртка для управления аддонами) – теперь берётся из оверлея
    (bottles.override { removeWarningPopup = true; })
    goverlay
    lutris
    heroic
    mangohud

    # МУЗЫКА
    my-packages.reaper                      # REAPER – цифровая звуковая рабочая станция (DAW) БЕРЕТСЯ ИЗ НЕСТАБИЛЬНОГО КАНАЛА!!!!
    yabridge                                # Мост для запуска Windows VST-плагинов в Linux (через Wine)
    yabridgectl                             # Утилита для управления yabridge (сканирование, синхронизация)
    winetricks                              # Вспомогательный скрипт для настройки Wine (установка DLL, зависимостей)
    coppwr                                  # Графическая утилита для управления PipeWire (альтернатива pw-top)
    vital                                   # Популярный синтезатор FM (VST-плагин)
    surge-xt                                # Синтезатор Surge XT (открытый код, мощный)
    geonkick                                # Синтезатор барабанов для создания ударных партий
    drumgizmo                               # Многоканальный сэмплер барабанов (реалистичные ударные)
    neural-amp-modeler-lv2                  # Плагин LV2 для моделирования гитарных усилителей (Neural Amp Modeler)
    dragonfly-reverb                        # Качественная реверберация Dragonfly (VST/LV2)
    fretboard                               # Гитаровый гриф / MIDI-инструмент (возможно, для обучения)

  ] ++ (with pkgs-unstable; [               # Пакеты из нестабильного канала (более свежие версии)
    # МУЗЫКА
    wineWow64Packages.staging               # Wine с поддержкой 64 и 32 бит (staging‑патчи для аудио)
    reaper-sws-extension                    # Расширение SWS для REAPER (дополнительные команды и автоматизация)
    reaper-reapack-extension                # Менеджер скриптов ReaPack для REAPER (установка пользовательских скриптов)
  ]);
}
