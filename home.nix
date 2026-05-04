{ config, pkgs, inputs, lib, ... }:
let
  pkgs-unstable = import inputs.nixpkgs-unstable {
    system = "x86_64-linux";
    config.allowUnfree = true;
  };
in

{
  # Импорт plasma-manager
  imports = [
    inputs.plasma-manager.homeModules.plasma-manager
  ];


# СИМВОЛИЧЕСКАЯ ССЫЛКА, ЧТОБЫ WINETRICKS НЕ РУГАЛСЯ НА ОТСУТСТВИЕ WINЕ64
home.activation.createWine64Link = lib.hm.dag.entryAfter ["writeBoundary"] ''
  mkdir -p $HOME/.local/bin
  ln -sf ${pkgs-unstable.wineWow64Packages.staging}/bin/wine $HOME/.local/bin/wine64
'';

home.activation.createVst3Dir = lib.hm.dag.entryAfter ["writeBoundary"] ''
  mkdir -p $HOME/.vst3
'';


  # ========== УПРАВЛЕНИЕ KDE Plasma ==========
  home.file.".wallpaper.jpg".source = ./dotfiles/wallpapers/Velo_01.JPG;
programs.plasma.workspace.wallpaper = "${config.home.homeDirectory}/.wallpaper.jpg";

      # Настройки клавиатуры
  configFile."kxkbrc" = {
    Layout = {
      LayoutList = "us,ru";
      LayoutLoopCount = "-1";                           # Бесконечный цикл переключения
      ResetOldOptions = "true";                         # Сбросить старые опции
      Options = "grp:ctrl_shift_toggle,grp_led:scroll"; # Переключение: Ctrl+Shift, индикатор на Scroll Lock
      ShowLayoutIndicator = "true";                     # Показывать индикатор раскладки в трее
      SwitchMode = "Global";                            # Глобальное переключение (для всей системы)
      Use = "true";                                     # Использовать эти настройки
      VariantList = "";                                 # Нет вариантов раскладок
    };
  };

      # Горячие клавиши
  shortcuts = {
    # Глобальные клавиши для всех приложений

      # Yakuake toggle
    yakuake = {
      "toggle-window-state" = "Meta+Z";  # "toggle-window-state" - действие: показать/скрыть окно Yakuake Win + Z
    };
  };
};

      # ========== МУЗЫКА НАСТРОЙКА!!!! ==========
    # Устанавливаем переменную окружения для пользовательской папки VST3
home.sessionVariables = {
  VST3_PATH = "${config.home.homeDirectory}/.vst3";
  WINEPREFIX = "/mnt/music/wine-yabridge";
};

  # ====================================================

  # НАСТРОЙКИ HOME MANAGER
  home.username = "lucerno";
  home.homeDirectory = "/home/lucerno";
  home.stateVersion = "25.11";
  programs.home-manager.enable = true;


  # Пакеты для пользователя
  home.packages = with pkgs; [
    nh
    # KDE приложения
    kdePackages.kde-gtk-config
    kdePackages.ktorrent
    kdePackages.kdenlive
    kdePackages.yakuake
    kdePackages.kcalc

    # ГРАФИКА
    pinta
    krita
    gimp
    inkscape
    blender
    upscaler

    # ИГРЫ
    (bottles.override { removeWarningPopup = true; })
    goverlay
    lutris
    heroic

    # ИНТЕРНЕТ
    parabolic
    discord
    telegram-desktop

    # МУЛЬТИМЕДИА
    vlc
    qmmp

    # МУЗЫКА
    yabridge
    yabridgectl
    winetricks                # для настройки префиксов
    coppwr

    vital                     # синтезатор FM
    surge-xt                  # синтезатор FM
    geonkick                  # синтезатор барабанов
    drumgizmo               # сэмплер барабанов (0.9.20)
    dragonfly-reverb
    fretboard


    # ОФИС

    # ВСЯКОЕ
    bat      # аналог cat с подсветкой синтаксиса
    btop
    mission-center
    fastfetch
    nix-tree

    # Minion обёртка
  (writeShellScriptBin "minion" ''
    export JAVA_TOOL_OPTIONS="-Dprism.lcdtext=false -Dprism.text=t2k"
    exec ${pkgs.minion}/bin/minion "$@"
  '')
  ] ++ (with pkgs-unstable; [
    # из нестабильного
    wineWow64Packages.staging
    reaper
    reaper-sws-extension
    reaper-reapack-extension
  ]);

programs.obs-studio = {
  enable = true;
  package = pkgs.obs-studio.override { cudaSupport = true; };
  plugins = with pkgs.obs-studio-plugins; [
    wlrobs
    obs-multi-rtmp
  ];
};

# ========== MANGO HUD ==========
programs.mangohud = {
  enable = true;
  enableSessionWide = false;
  settings = {
    fps = true;
    cpu_temp = true;
    gpu_temp = true;
    ram = true;
    vram = true;
    winesync = true;
    position = "top-right";
    font_size = 24;
    background_alpha = 0.5;
    full = true;
  };
};

# ========== УПРАВЛЕНИЕ ФАЙЛАМИ ПОЛЬЗОВАТЕЛЯ ==========
home.file = {

  # XDG пользовательские директории
".config/user-dirs.dirs" = {
  text = ''
    XDG_DESKTOP_DIR="$HOME/Desktop"
    XDG_DOWNLOAD_DIR="$HOME/Загрузки"
    XDG_TEMPLATES_DIR="$HOME/Templates"
    XDG_PUBLICSHARE_DIR="$HOME/Public"
    XDG_DOCUMENTS_DIR="/mnt/docs"
    XDG_MUSIC_DIR="/mnt/music"
    XDG_PICTURES_DIR="/mnt/images"
    XDG_VIDEOS_DIR="/mnt/video"
  '';
      force = true;
  };

  # --- Автозапуск AmneziaVPN ---
  # Создаёт .desktop-файл, который запускает AmneziaVPN при входе в KDE.
  ".config/autostart/amneziavpn.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=AmneziaVPN
    Exec=amnezia-vpn
    Icon=amnezia-vpn
    X-KDE-autostart-after=panel
    StartupNotify=false
    Terminal=false
  '';

  # --- Автозапуск Yakuake ---
  # Создаёт .desktop-файл для запуска Yakuake (выпадающий терминал).
  # sleep 2 даёт время на полную загрузку KDE перед стартом.
  ".config/autostart/yakuake.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=Yakuake
    Exec=bash -c "sleep 2 && yakuake"
    Icon=yakuake
    X-KDE-autostart-after=panel
    StartupNotify=false
    Terminal=false
  '';


  # --- Кастомный запуск REAPER с GDK_BACKEND=x11 ---
  ".local/bin/reaper" = {
    source = /home/lucerno/nixos-config/scripts/reaper;
    executable = true;
  };

  # --- Ярлык REAPER в меню KDE ---
".local/share/applications/reaper-x11.desktop" = {
  text = ''
    [Desktop Entry]
    Version=1.0
    Type=Application
    Name=REAPER
    Comment=ПРОСТО БОЛЬ !!!
    Exec=/home/lucerno/.local/bin/reaper %F
    Icon=cockos-reaper
    Categories=Audio;AudioVideo;
    Terminal=false
    StartupWMClass=REAPER
    '';
    force = true;
  };

  # --- Ярлык Minion в меню KDE ---
  ".local/share/applications/minion.desktop" = {
    text = ''
      [Desktop Entry]
      Version=1.0
      Type=Application
      Name=Minion
      Comment=Управление аддонами для MMORPG
      Exec=minion
      Icon=/mnt/images/sys-icons/icon-minion.png
      Categories=Game;
      Terminal=false
      StartupWMClass=Minion
    '';
    force = true;
  };

  # --- Ярлык QMMP ---
    ".local/bin/qmmp-wayland-fix".source = /home/lucerno/nixos-config/scripts/qmmp-wayland-fix;
    ".local/bin/qmmp-wayland-fix".executable = true;

      ".local/share/applications/org.qmmp.qmmp.desktop" = {
    text = ''
  [Desktop Entry]
  Name=Qmmp
  Exec=/home/lucerno/.local/bin/qmmp-wayland-fix %F
  Icon=qmmp
  Terminal=false
  Type=Application
  Categories=Audio;AudioVideo;
'';
    force = true;
  };

  # --- Ярлык Ampero ---
".local/share/applications/ampero2.desktop" = {
  text = ''
    [Desktop Entry]
    Type=Application
    Name=Ampero II
    Comment=Hotone Ampero II Editor
    Exec=env WINEPREFIX="/mnt/music/wine/wine-guitar" wine "/mnt/music/wine/wine-guitar/drive_c/Program Files/Hotone/Ampero II/Ampero II.exe"
    Icon=/home/lucerno/nixos-config/dotfiles/sys-icons/icon-hotone.png
    Categories=Audio;AudioVideo;
    StartupNotify=true
    Terminal=false
  '';
  force = true;
};

      # Игнорируем папки в гит репозитории (Через какую же жопу оно работает!!! Что игнорит гит папки и для копирования на гит хаб и для сборки системы аааааааа)
  "nixos-config/.gitignore" = {
  text = ''
    dotfiles/
    secrets/
    .Trash-1000/
  '';
};

  # Ссылка REAPER для SWS
  ".config/REAPER/UserPlugins/reaper_sws-x86_64.so".source = "${pkgs-unstable.reaper-sws-extension}/UserPlugins/reaper_sws-x86_64.so";

  # Ссылка REAPER для ReaPack
  ".config/REAPER/UserPlugins/reaper_reapack-x86_64.so".source = "${pkgs-unstable.reaper-reapack-extension}/UserPlugins/reaper_reapack-x86_64.so";
};
# ===================================================


  # ========== ZSH НАСТРОЙКА ==========
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    # Oh My Zsh
    oh-my-zsh = {
      enable = true;                      # Включает Oh My Zsh (коллекция тем и плагинов)
      theme = "agnoster";                 # тема с информацией о git ветке
      plugins = [                         # Список плагинов
        "git"                             # Алиасы для Git (сокращает время набора) - gst, ga, gc, gp
        "docker"                          # Алиасы для Docker - dps, drm, dstop
        "sudo"                            # Добавляет sudo перед последней командой [Esc][Esc]
        "extract"                         # Распаковывает любой архив (7z, rar, zip, tar...) extract file.zip
        "web-search"                      # Поиск в браузере прямо из терминала - google nixos, youtube linux
        "command-not-found"               # Предлагает установить пакет через nix - неизвестная_команда
        "colored-man-pages"               # Цветные man страницы - man ls
        "history"                         # Показывает историю команд - h или history
        "npm"                             # Автодополнения
        "node"                            # Автодополнения
        "python"                          # Автодополнения
      ];
    };

    # Настройки истории
    history = {
      size = 10000;                       # Сколько команд хранить в памяти
      path = "$HOME/.zsh_history";        # Файл с историей
      share = true;                       # Общая история между всеми терминалами
      save = 10000;                       # Сколько команд сохранять в файл
# Полезные команды:
# показать историю - history
# повторить последнюю команду - !!
# выполнить команду под номером 123 - !123
# выполнить последнюю команду начинающуюся с ls - !ls
# поиск по истории - Ctrl+R
    };

    # Алиасы
    shellAliases = {
      ll = "ls -la";
      la = "ls -a";
      l = "ls -l";
      gs = "git status";
      gp = "git pull";
      gc = "git commit -m";
      gco = "git checkout";
      gb = "git branch";
      nrs = "sudo nixos-rebuild switch --impure --flake .#Lucerno-PC";
      nrb = "sudo nixos-rebuild boot --impure --flake .#Lucerno-PC";
      hm = "export NIXPKGS_ALLOW_UNFREE=1 && nix run github:nix-community/home-manager -- switch --flake .#lucerno --impure";
      update = "nix flake update && sudo nixos-rebuild switch --impure --flake .#Lucerno-PC";
    };

    # Дополнительные настройки в .zshrc
    initContent = ''
      # Переменные окружения для игр
      export PROTON_USE_NTSYNC=1
      export PROTON_NO_ESYNC=1
      export PROTON_NO_FSYNC=1

      # Разрешение unfree пакетов для home-manager
      export NIXPKGS_ALLOW_UNFREE=1

      # Путь к локальным скриптам
      export PATH="$HOME/.local/bin:$PATH"

      # Утилиты для удобства
      alias cat="bat"
      alias top="btop"

      # Промпт
      PROMPT='%F{green}%n@%m%f:%F{blue}%~%f$ '
      RPROMPT='%F{red}$(git branch --show-current 2>/dev/null)%f'
    '';
  };
  # =================================

}
