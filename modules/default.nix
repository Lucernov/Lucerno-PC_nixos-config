# modules/default.nix
{ config, pkgs, lib, pkgs-unstable, inputs, ... }:

{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  system.stateVersion = "25.11";

  imports = [
    ../hardware-configuration.nix

    ./nx_sddm.nix
    ./nx_locale.nix
    ./nx_users.nix
    ./nx_firewall.nix
    ./nx_pipewire.nix
    ./nx_steam.nix
    ./nx_thunar.nix
    ./nx_optimization.nix
    ./nx_configuration-kde_plasma.nix
  ];

  # ========== Загрузчик ==========
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
    systemd-boot.consoleMode = "max";
  };
  boot.supportedFilesystems = [ "exfat" ];
  #system.nixos-init.enable = true;                        # иногда проверять, пока проблемы с нвидиа

  boot.extraModprobeConfig = ''
    options btusb enable_autosuspend=0
  '';


  # ========== Аудио оптимизация (musnix) ==========
  musnix.enable = true;
  musnix.kernel.realtime = false;                          # для совместимости с NVIDIA

  # ========== Включение системных модулей для программ ==========
  programs.git.enable = true;           # Включает поддержку Git (утилита системы контроля версий)
  programs.dconf.enable = true;         # Включает dconf – базу данных настроек для GTK-приложений (необходим для тем, шрифтов и т.п.)
  programs.zsh.enable = true;           # Устанавливает Zsh как системную оболочку (для всех пользователей)
  programs.vim.enable = true;           # Устанавливает Vim (текстовый редактор) системно
  programs.nano.enable = true;          # Устанавливает Nano (простой текстовый редактор) системно
  programs.htop.enable = true;          # Устанавливает htop (интерактивный монитор процессов) системно
  programs.amnezia-vpn.enable = true;   # Включает сервис AmneziaVPN (VPN-клиент)

  # ========== Дополнительные системные пакеты (устанавливаются вручную) ==========
  environment.systemPackages = with pkgs; [
    iw
    wirelesstools
    lf                                  # "List Files" – быстрый файловый менеджер на Go с vim-подобным управлением
    mc                                  # Midnight Commander – классический двухпанельный файловый менеджер (FTP, просмотр, редактор)
    yazi
    unzip                               # Утилита для распаковки ZIP-архивов
    curl                                # Инструмент для передачи данных по сети (HTTP, FTP и др.)
    wget                                # Утилита для загрузки файлов из интернета
    # carbonyl                          # Консольный браузер
    nvtopPackages.nvidia                # Монитор использования видеокарты NVIDIA в консоли
    wayland-utils                       # Набор утилит для диагностики Wayland (например, wayland-info)
    gsettings-desktop-schemas           # Схемы настроек для GSettings (используются GTK-приложениями)
    glib                                # Базовая библиотека GLib (низкоуровневые структуры данных)
    libva-utils                         # Утилиты для VA-API (аппаратное ускорение видео)

    gearlever
    google-chrome                       # Браузер Google Chrome
  ];

  # ========== Переменные окружения для Wayland и NVIDIA ==========
  environment.sessionVariables = {
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";                                                  # Принудительно указываем Vulkan-драйвер NVIDIA для OpenGL/GLX приложений (чтобы программы использовали NVidia, а не, например, llvmpipe)
    __GL_VRR_ALLOWED = "1";                                                                # Разрешает Variable Refresh Rate (VRR / G-Sync / FreeSync) Включает адаптивную синхронизацию для совместимых мониторов
    GBM_BACKEND = "nvidia-drm";                                                            # Указывает бэкенд Graphics Buffer Manager (GBM) от NVIDIA. Необходимо для корректной работы Wayland с проприетарным драйвером
    CHROME_FLAGS = "--ozone-platform-hint=auto";                                           # Флаги для браузеров на базе Chromium (Chrome, Edge, Brave и др.) Принудительно включает поддержку Wayland через Ozone
    ELECTRON_OZONE_PLATFORM_HINT = "auto";                                                 # Для приложений на Electron (VS Code, Discord, Telegram и др.) Заставляет их использовать Wayland вместо XWayland
    QT_QPA_PLATFORM = "wayland";                                                           # Задаёт бэкенд Qt для работы через Wayland (вместо X11)
    GDK_BACKEND = "wayland";                                                               # Указывает GTK-приложениям использовать Wayland
    SDL_VIDEODRIVER = "wayland";                                                           # Задаёт драйвер для SDL (используется в играх и мультимедиа) – Wayland
    QT_QPA_PLATFORM_PLUGIN_PATH = "${pkgs.qt6.qtwayland}/lib/qt-6/plugins/platforms";      # Путь к плагинам Qt для поддержки Wayland. Без этого некоторые Qt-приложения могут не запускаться под Wayland
    NIXOS_OZONE_WL = "1";
    WLR_NO_HARDWARE_CURSORS = "1";
    EGL_PLATFORM = "wayland";
    #WLR_RENDERER_ALLOW_SOFTWARE = "1";
  };

  # ========== мои симлинки ==========
  systemd.tmpfiles.rules = [
    "L+ /home/lucerno/drum_sklad - - - - /mnt/sys_archiv/samples/drum_sklad"
    "d /home/lucerno/.local/share 0755 lucerno lucerno -"
    "L+ /home/lucerno/.local/share/Steam/userdata - - - - /home/lucerno/nixos-config/dotfiles/config/Steam/userdata"
    "L+ /home/lucerno/.local/share/vital - - - - /mnt/sys_archiv/samples/vital"
    "d /home/lucerno/.config 0755 lucerno lucerno -"
    "L+ /home/lucerno/.config/AmneziaVPN.ORG - - - - /home/lucerno/nixos-config/dotfiles/config/AmneziaVPN.ORG"
    "L+ /home/lucerno/.config/obs-studio - - - - /home/lucerno/nixos-config/dotfiles/config/obs-studio"
    "L+ /home/lucerno/.config/DecentSampler - - - - /mnt/sys_archiv/samples/DecentSampler"
    "L+ /home/lucerno/.config/REAPER - - - - /home/lucerno/nixos-config/dotfiles/config/REAPER"
    "L+ /home/lucerno/.config/yabridgectl - - - - /home/lucerno/nixos-config/dotfiles/config/yabridgectl"
    "L+ /home/lucerno/.local/share/Steam/steamapps - - - - /mnt/games/SteamLibrary/steamapps"
  ];


}
