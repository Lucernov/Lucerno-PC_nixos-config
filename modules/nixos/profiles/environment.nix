{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    home-manager
    git
    unzip
    kdePackages.plasma-desktop
    kdePackages.breeze-gtk
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

  # ========== Переменные окружения для менеджера входа ==========
  environment.sessionVariables = {
    LANG = "ru_RU.UTF-8";
    LANGUAGE = "ru_RU.UTF-8";
  # ========== Переменные окружения для Wayland ==========
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";               # Принудительно указываем Vulkan-драйвер NVIDIA
    __GL_VRR_ALLOWED = "1";
    GBM_BACKEND = "nvidia-drm";                         # Указываем бэкенд для GBM (Graphics Buffer Manager)
    CHROME_FLAGS = "--ozone-platform-hint=auto";
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
    QT_QPA_PLATFORM = "wayland";
    GDK_BACKEND = "wayland";
    SDL_VIDEODRIVER = "wayland";
    QT_QPA_PLATFORM_PLUGIN_PATH = "${pkgs.qt6.qtwayland}/lib/qt-6/plugins/platforms";
    #LD_LIBRARY_PATH = "/run/current-system/sw/lib";
    #QT_PLUGIN_PATH = "/run/current-system/sw/lib/qt-6/plugins";
  };
}
