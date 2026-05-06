{ pkgs, ... }:

{
  services.displayManager.sddm = {
    enable = true;                                                # Включает SDDM (Simple Desktop Display Manager)
    wayland.enable = true;                                        # Разрешает SDDM работать под Wayland
  };
  #services.displayManager.plasma-login-manager.enable = true;    # Plasma Login Manager (PLM) — это новый менеджер входа

  # ПОДМЕНА ФОНА SDDM
  # файл theme.conf.user внутри темы breeze. SDDM читает этот файл и применяет настройки, не затрагивая оригинальные файлы темы.
  # Параметр background указывает на пакет mySddmBackground
  environment.systemPackages = [
    (pkgs.writeTextDir "share/sddm/themes/breeze/theme.conf.user" ''
      [General]
      background=${pkgs.copyPathToStore (toString ../../../dotfiles/wallpapers/Velo_01.JPG)}
    '')
  ];

    # ========== Переменные окружения для менеджера входа ==========
  environment.sessionVariables = {
    LANG = "ru_RU.UTF-8";
    LANGUAGE = "ru_RU.UTF-8";
}

