{ pkgs, ... }:

let
  myLib = import ../lib.nix;
  wallpaper = myLib.wallpaperPath;
in
{
  # ========== Настройка дисплейного менеджера SDDM ==========
  services.displayManager.sddm = {
    enable = true;                                                  # Включаем SDDM (Simple Desktop Display Manager)
    wayland.enable = true;                                          # Разрешаем SDDM работать под Wayland (иначе будет X11)
  };
  # services.displayManager.plasma-login-manager.enable = true;     # Альтернативный менеджер входа Plasma Login Manager (пока не используется)

  # ========== Настройка фона SDDM ==========
  environment.systemPackages = [                                    # Создаём пакет с пользовательским конфигурационным файлом для темы Breeze
    (pkgs.writeTextDir "share/sddm/themes/breeze/theme.conf.user" ''
      [General]
      # Указываем путь к изображению, которое будет фоном экрана входа pkgs.copyPathToStore копирует файл в /nix/store для воспроизводимости
      background=${wallpaper}
    '')
  ];

  # ========== Переменные окружения для сессии SDDM ==========
  environment.sessionVariables = {                                   # Локаль для интерфейса SDDM (русский язык)
    LANG = "ru_RU.UTF-8";
    LANGUAGE = "ru_RU.UTF-8";
  };
}
