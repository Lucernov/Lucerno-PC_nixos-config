{ pkgs, ... }:

{
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
    # (закомментировано) Ручное указание путей к библиотекам — обычно не требуется
    # LD_LIBRARY_PATH = "/run/current-system/sw/lib";
    # QT_PLUGIN_PATH = "/run/current-system/sw/lib/qt-6/plugins";
  };
}
