{ pkgs, ... }:

{
  # ========== Переменные окружения для Wayland ==========
  environment.sessionVariables = {
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
