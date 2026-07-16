{ pkgs, pkgs-unstable, myLib, ... }:

let
  packages = import ../packages.nix { inherit myLib pkgs pkgs-unstable; };
in

{
  programs.home-manager.enable = true;                                                                # Включает Home Manager как системный модуль (управление пользовательским окружением)

  home = {                                                                                            # НАСТРОЙКИ HOME MANAGER
    stateVersion = myLib.channelVersion;                                                              # Версия NixOS
    username = myLib.userName;                                                                        # Имя пользователя
    homeDirectory = myLib.home;                                                                       # Домашняя директория
    sessionPath = [ "${myLib.home}/.local/bin" ];                                                     # Добавляем .local/bin в $PATH
    packages = packages.homePackages;                                                                 # Импорт пакетов, установленных через Home Manager
  };
}
