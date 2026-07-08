{ config, pkgs, pkgs-unstable, lib, myLib, ... }:

let
  links = import ../links.nix { inherit pkgs lib myLib config; };
  packages = import ../packages.nix { inherit myLib pkgs pkgs-unstable; };
in

{
  programs.home-manager.enable = true;                                                                # Включает Home Manager как системный модуль (управление пользовательским окружением)

  home = {                                                                                            # НАСТРОЙКИ HOME MANAGER
    stateVersion = myLib.channelVersion;                                                              # Версия NixOS
    username = myLib.userName;                                                                        # Имя пользователя
    homeDirectory = myLib.home;                                                                       # Домашняя директория
    sessionPath = [ "${myLib.home}/.local/bin" ];                                                     # Добавляем .local/bin в $PATH
    activation = { createLinks = lib.hm.dag.entryAfter [ "writeBoundary" ] links.activationScript; }; # Добавляем активацию (создание директорий и симлинков)
    sessionVariables = {
      VST3_PATH = "${config.home.homeDirectory}/.vst3";                                               # Устанавливаем переменную окружения для пользовательской папки VST3
      WINEPREFIX = "/mnt/music/wine-yabridge";                                                        # Префикс Wine для Windows-плагинов, используемых через yabridge
    };

    packages = packages.homePackages;                                                                 # Импорт пакетов, установленных через Home Manager
  };
}
