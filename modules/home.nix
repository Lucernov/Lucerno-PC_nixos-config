{ config, pkgs, pkgs-unstable, inputs, lib, ... }:

{
home.stateVersion = "25.11";

  # НАСТРОЙКИ HOME MANAGER
  home.username = "lucerno";
  home.homeDirectory = "/home/lucerno";

  home.sessionVariables = {
    VST3_PATH = "${config.home.homeDirectory}/.vst3";  # Устанавливаем переменную окружения для пользовательской папки VST3
    WINEPREFIX = "/mnt/music/wine-yabridge";
  };

  # Импорт plasma-manager
  imports = [
    inputs.plasma-manager.homeModules.plasma-manager

    ./home-file.nix

    ./hx_music.nix
    ./hx_plasma.nix    # настройки KDE Plasma (горячие клавиши, обои)
    ./hx_zsh.nix
    ./hx_git.nix
    ./hx_obs.nix
    ./hx_kitty.nix
  ];

  # ========== Включение модулей программ (через home-manager) ==========
  # Эти модули не только устанавливают пакеты, но и позволяют централизованно настраивать их через атрибуты (например, programs.btop.settings).
  programs.home-manager.enable = true;  # Включает Home Manager как системный модуль (управление пользовательским окружением)
  programs.btop.enable = true;          # Монитор ресурсов с графическим интерфейсом в терминале
  programs.bat.enable = true;           # Улучшенный аналог cat с подсветкой синтаксиса

  # ========== Пакеты, устанавливаемые простым способом ==========
  home.packages = with pkgs; [
    nh                                  # Утилита для удобного управления Nix
    lsof                                # Просмотр открытых файлов и сокетов

    # KDE приложения (графические, не требующие системной интеграции)
    kdePackages.ktorrent                # Torrent-клиент
    kdePackages.kdenlive                # Видеоредактор
    # kdePackages.yakuake               # Выпадающий терминал (закомментирован, не используется)
    kdePackages.kcalc                   # Калькулятор

    # ГРАФИКА
    upscaler
    pinta                               # Простой растровый редактор
    krita                               # Цифровая живопись
    gimp                                # Мощный растровый редактор
    inkscape                            # Векторная графика
    blender                             # 3D-моделирование
    upscaler                            # Увеличение разрешения изображений

    # ИНТЕРНЕТ
    parabolic                           # Загрузчик видео/аудио с YouTube (альтернатива yt-dlp)
    discord                             # Голосовой/текстовый чат
    telegram-desktop                    # Мессенджер Telegram

    # МУЛЬТИМЕДИА
    vlc                                 # Универсальный видеоплеер
    qmmp                                # Аудиоплеер (похож на Winamp)
    deadbeef

    # ИГРЫ
    (bottles.override { removeWarningPopup = true; })
    goverlay
    lutris
    heroic

    # ВСЯКОЕ
    mission-center                      # Графический монитор системы (альтернатива btop)
    fastfetch                           # Вывод информации о системе (аналог neofetch)
    nix-tree                            # Просмотр дерева зависимостей Nix

    my-packages.parabolic               # Кастомный пакет parabolic (обёртка для управления аддонами) – теперь берётся из оверлея
    my-packages.minion                  # Кастомный пакет minion (обёртка для управления аддонами) – теперь берётся из оверлея

  ] ++ (with pkgs-unstable; [

  ]);
}
