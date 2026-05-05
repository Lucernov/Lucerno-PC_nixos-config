{ config, pkgs, ... }:

{
  # Wayland + KDE Plasma 6
  services.displayManager.sddm.enable = true;                     # Включает SDDM (Simple Desktop Display Manager)
  services.displayManager.sddm.wayland.enable = true;             # Разрешает SDDM работать под Wayland
  #services.displayManager.plasma-login-manager.enable = true;    # Plasma Login Manager (PLM) — это новый менеджер входа
  services.desktopManager.plasma6.enable = true;                  # Включает рабочий стол KDE Plasma 6
  services.displayManager.defaultSession = "plasma";              # Устанавливает сеанс по умолчанию — Plasma (KDE)
  services.xserver.enable = false;                                # Отключает X11-сервер полностью
  programs.dconf.enable = true;                                   # Включает систему хранения настроек dconf
  programs.partition-manager.enable = true;                       # Устанавливает KDE Partition Manager
}
