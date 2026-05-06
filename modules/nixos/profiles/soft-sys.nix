{ pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;      # Разрешение unfree пакетов
  programs.dconf.enable = true;           # Включает систему хранения настроек dconf
  programs.zsh.enable = true;             # консоль оболочка для всех пользователей
  programs.amnezia-vpn.enable = true;     # AmneziaVPN

  environment.systemPackages = with pkgs; [
    home-manager
    git
    unzip
    vim                       # консоль системный текстовый редактор
    nano                      # консоль системный текстовый редактор
    curl
    wget
    htop
    #carbonyl                 # консольный Браузер
    nvtopPackages.nvidia      # консоль телеметрия видеокарты
    wayland-utils             # системные утилиты Wayland
    gsettings-desktop-schemas # системные схемы
    glib                      # системная библиотека
    nvidia-vaapi-driver       # драйвера видеокарты
    libva-utils               # системные утилиты VA-API

    google-chrome             # браузер
  ];
};
