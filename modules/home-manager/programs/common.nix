{ pkgs, pkgs-unstable, ... }:

{
  # ========== Включение модулей программ (через home-manager) ==========
  # Эти модули не только устанавливают пакеты, но и позволяют централизованно настраивать их через атрибуты (например, programs.btop.settings).
  programs.btop.enable = true;      # Монитор ресурсов с графическим интерфейсом в терминале
  programs.bat.enable = true;       # Улучшенный аналог cat с подсветкой синтаксиса
  programs.kitty.enable = true;     # Терминал с аппаратным ускорением (GPU)

  # ========== Пакеты, устанавливаемые простым способом ==========
  home.packages = with pkgs; [
    nh                              # Утилита для удобного управления Nix
    lsof                            # Просмотр открытых файлов и сокетов

    # KDE приложения (графические, не требующие системной интеграции)
    kdePackages.kde-gtk-config      # Настройка GTK-тем для KDE
    kdePackages.ktorrent            # Torrent-клиент
    kdePackages.kdenlive            # Видеоредактор
    # kdePackages.yakuake           # Выпадающий терминал (закомментирован, не используется)
    kdePackages.kcalc               # Калькулятор

    # ГРАФИКА
    pinta                           # Простой растровый редактор
    krita                           # Цифровая живопись
    gimp                            # Мощный растровый редактор
    inkscape                        # Векторная графика
    blender                         # 3D-моделирование
    upscaler                        # Увеличение разрешения изображений

    # ИНТЕРНЕТ
    parabolic                       # Загрузчик видео/аудио с YouTube (альтернатива yt-dlp)
    discord                         # Голосовой/текстовый чат
    telegram-desktop                # Мессенджер Telegram

    # МУЛЬТИМЕДИА
    vlc                             # Универсальный видеоплеер
    qmmp                            # Аудиоплеер (похож на Winamp)

    # ВСЯКОЕ
    mission-center                  # Графический монитор системы (альтернатива btop)
    fastfetch                       # Вывод информации о системе (аналог neofetch)
    nix-tree                        # Просмотр дерева зависимостей Nix

    # Minion обёртка (для управления аддонами в MMORPG)
    (writeShellScriptBin "minion" ''
      export JAVA_TOOL_OPTIONS="-Dprism.lcdtext=false -Dprism.text=t2k"
      exec ${pkgs.minion}/bin/minion "$@"
    '')
  ] ++ (with pkgs-unstable; [
    # Пакеты из нестабильного канала добавлять сюда
  ]);
}
