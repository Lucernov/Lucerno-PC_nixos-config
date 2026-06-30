{ config, pkgs, pkgs-unstable, lib, myLib, ... }:

let
  links = import ../links.nix { inherit pkgs lib myLib config; };
  packages = import ../packages.nix { inherit pkgs pkgs-unstable; };
in

{
  # НАСТРОЙКИ HOME MANAGER
  home.stateVersion = myLib.channelVersion;            # Версия NixOS
  home.username = myLib.userName;                      # Имя пользователя
  home.homeDirectory = myLib.home;                     # Домашняя директория


  home.activation = {                                  # Добавляем активацию (создание директорий и симлинков)
    createLinks = lib.hm.dag.entryAfter [ "writeBoundary" ] links.activationScript;
  };

  home.sessionVariables = {
    VST3_PATH = "${config.home.homeDirectory}/.vst3";  # Устанавливаем переменную окружения для пользовательской папки VST3
    WINEPREFIX = "/mnt/music/wine-yabridge";           # Префикс Wine для Windows-плагинов, используемых через yabridge
  };

  # ========== Включение модулей программ (через home-manager) ==========
  # Эти модули не только устанавливают пакеты, но и позволяют централизованно настраивать их через атрибуты (например, programs.btop.settings)
  programs.home-manager.enable = true;                 # Включает Home Manager как системный модуль (управление пользовательским окружением)

  home.packages = packages.homePackages;               # Импорт пакетов, установленных через Home Manager

}
