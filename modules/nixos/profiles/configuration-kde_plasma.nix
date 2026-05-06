{ config, pkgs, ... }:

{
  services.desktopManager.plasma6.enable = true;            # Подключает все необходимые системные службы, компоненты и настройки, чтобы KDE Plasma 6 могла работать в качестве основной графической среды
  services.displayManager.defaultSession = "plasma";        # Указывает, какая сессия рабочего стола будет запускаться по умолчанию. Значение "plasma" соответствует KDE Plasma (может быть "plasma" или "plasmawayland")
  services.xserver.enable = false;                          # Запрещает запуск X11-сервера. Это означает, что вся графика будет работать через Wayland
  programs.partition-manager.enable = true;                 # Включает модуль для утилиты управления разделами диска (KDE Partition Manager)

  # ========== Дополнительные системные пакеты для Plasma ==========
  environment.systemPackages = with pkgs; [
    kdePackages.breeze-gtk                                  # Обеспечивает единый внешний вид GTK-программ в окружении KDE Plasma
  ];
}
