{ config, pkgs, myLib, ... }:

{
  # ========== Настройка дисплейного менеджера SDDM ==========
  services.displayManager.sddm = {
    enable = true;                                                  # Включаем SDDM (Simple Desktop Display Manager)
    wayland.enable = true;                                          # Разрешаем SDDM работать под Wayland (иначе будет X11)
  };
  #services.displayManager.plasma-login-manager.enable = true;      # менеджер входа Plasma Login Manager

  # ========== Переменные окружения для сессии SDDM ==========
  environment.sessionVariables = {                                  # Локаль для интерфейса SDDM (русский язык)
    LANG = "ru_RU.UTF-8";
    LANGUAGE = "ru_RU.UTF-8";
    QT_QPA_PLATFORMTHEME = "kde";
  };

  services.desktopManager.plasma6.enable = true;                    # Подключает все необходимые системные службы, компоненты и настройки, чтобы KDE Plasma 6 могла работать в качестве основной графической среды
  services.displayManager.defaultSession = "plasma";                # Указывает, какая сессия рабочего стола будет запускаться по умолчанию. Значение "plasma" соответствует KDE Plasma (может быть "plasma" или "plasmawayland")
  services.xserver.enable = false;                                  # Запрещает запуск X11-сервера. Вся графика будет работать через Wayland

  # ========== Дополнительные системные пакеты для Plasma ==========
  environment.systemPackages = with pkgs; [
    kdePackages.breeze-gtk                                          # Обеспечивает единый внешний вид GTK-программ в окружении KDE Plasma
    kdePackages.kde-gtk-config                                      # Настройка GTK-тем для KDE

    # ========== Настройка фона SDDM ==========
    (writeTextDir "share/sddm/themes/breeze/theme.conf.user" ''
      [General]
      background=${myLib.wallpaperPath}
    '')
  ];
}
