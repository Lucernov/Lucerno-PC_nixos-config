#nixos-config/
#├── flake.nix                     # точка входа для Nix
#└── modules/
#    ├── home-manager/             # все модули для home-manager
#    │   ├── programs/             # ⭐ модули для НАСТРОЙКИ ПРОГРАММ
#    │   │   ├── zsh.nix
#    │   │   ├── git.nix
#    │   │   ├── kitty.nix
#    │   │   ├── reaper.nix        # здесь всё, что конфигурится через home-manager
#    │   │   └── gaming.nix        # lutris, heroic и т.д.
#    │   ├── services/             # ⭐ модули для ФОНОВЫХ СЕРВИСОВ ПОЛЬЗОВАТЕЛЯ
#    │   │   └── kde-no-file-limit.nix  # systemd сервисы (тот самый fix)
#    │   ├── misc/                 # ⭐ модули для РАЗНОГО
#    │   │   └── desktop-files.nix      # XDG, автозапуск, user-dirs
#    │   ├── music.nix             # "Дикий" модуль, который лежит прямо в папке home-manager
#    │   └── home.nix              # Корневой модуль, который всё это импортирует
#    └── nixos/ ...                # системные модули

{ config, pkgs, pkgs-unstable, inputs, lib, ... }:

{
  # Импорт plasma-manager
  imports = [
    inputs.plasma-manager.homeModules.plasma-manager
    ./programs/plasma.nix    # настройки KDE Plasma (горячие клавиши, обои)
    ./programs/zsh.nix
    ./programs/common.nix
  ];

# СИМВОЛИЧЕСКАЯ ССЫЛКА, ЧТОБЫ WINETRICKS НЕ РУГАЛСЯ НА ОТСУТСТВИЕ WINЕ64
home.activation.createWine64Link = lib.hm.dag.entryAfter ["writeBoundary"] ''
  mkdir -p $HOME/.local/bin
  ln -sf ${pkgs-unstable.wineWow64Packages.staging}/bin/wine $HOME/.local/bin/wine64
'';

home.activation.createVst3Dir = lib.hm.dag.entryAfter ["writeBoundary"] ''
  mkdir -p $HOME/.vst3
'';

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

  # --- Автозапуск Kitty ---
".config/autostart/kitty-quick-access.desktop".text = ''
  [Desktop Entry]
  Type=Application
  Name=Kitty Quick Access
  Exec=${pkgs.kitty}/bin/kitten quick-access-terminal
  Icon=kitty
  StartupNotify=false
  Terminal=false
  X-KDE-autostart-after=panel
'';

# ========== Kitty ==========
".config/kitty/quick-access-terminal.conf".text = ''
  size = 70% 50%
  position = center, center
  background_opacity = 0.85
  hide_window_decorations = yes
  confirm_os_window_close = 0
  foreground #eceff4
  background #2e3440
'';

".local/bin/toggle-kitty".source = /home/lucerno/nixos-config/scripts/toggle-kitty.sh;
".local/bin/toggle-kitty".executable = true;

".config/kitty/kitty.conf".text = ''
  # Открыть новую вкладку (в текущей рабочей директории)
  map ctrl+shift+t new_tab_with_cwd

  # Закрыть текущую вкладку
  map ctrl+shift+q close_tab

  # (Опционально) Переключение между вкладками
  map ctrl+shift+right next_tab
  map ctrl+shift+left  previous_tab

  # (Опционально) Привязать Meta (Win) + W для закрытия вкладки (как в браузере)
  map super+w close_tab
'';


  # --- Автозапуск Yakuake ---
  # Создаёт .desktop-файл для запуска Yakuake (выпадающий терминал).
  # sleep 2 даёт время на полную загрузку KDE перед стартом.
#  ".config/autostart/yakuake.desktop".text = ''
#    [Desktop Entry]
#    Type=Application
#    Name=Yakuake
#    Exec=bash -c "sleep 2 && yakuake"
#    Icon=yakuake
#    X-KDE-autostart-after=panel
#    StartupNotify=false
#    Terminal=false
#  '';


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

  # Ссылка REAPER для SWS
  ".config/REAPER/UserPlugins/reaper_sws-x86_64.so".source = "${pkgs-unstable.reaper-sws-extension}/UserPlugins/reaper_sws-x86_64.so";

  # Ссылка REAPER для ReaPack
  ".config/REAPER/UserPlugins/reaper_reapack-x86_64.so".source = "${pkgs-unstable.reaper-reapack-extension}/UserPlugins/reaper_reapack-x86_64.so";
};
# ===================================================



  programs.git = {
  enable = true;
  ignores = [ "*.swp" "*~" ".Trash-*" "result" ];
  settings = {
    user = {
      name = "Lucernov";
      email = "jin.riv@gmail.com";
    };
  };
};

}
