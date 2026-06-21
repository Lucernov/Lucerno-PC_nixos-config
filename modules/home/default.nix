{ config, pkgs, pkgs-unstable, inputs, lib, myLib, ... }:

let
  packages = import ../packages.nix { inherit pkgs pkgs-unstable; };
in

{
  # НАСТРОЙКИ HOME MANAGER
  home.stateVersion = myLib.channelVersion;            # Версия NixOS, на которой были созданы настройки home-manager. Используется для миграции конфигурации
  home.username = myLib.userName;                      # Имя пользователя, для которого применяется конфигурация
  home.homeDirectory = "/home/${myLib.userName}";      # Домашняя директория

  home.sessionVariables = {
    VST3_PATH = "${config.home.homeDirectory}/.vst3";  # Устанавливаем переменную окружения для пользовательской папки VST3
    WINEPREFIX = "/mnt/music/wine-yabridge";           # Префикс Wine для Windows-плагинов, используемых через yabridge
  };

  # ========== Включение модулей программ (через home-manager) ==========
  # Эти модули не только устанавливают пакеты, но и позволяют централизованно настраивать их через атрибуты (например, programs.btop.settings)
  programs.home-manager.enable = true;                 # Включает Home Manager как системный модуль (управление пользовательским окружением)

  home.packages = packages.homePackages;               # Импорт пакетов, установленных через Home Manager

  # Перенаправления ядер в дирректорию РетроАрч
  home.activation.createRetroArchCoresLink = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
  mkdir -p "$HOME/.config/retroarch"
  ln -sfn "${config.home.path}/lib/retroarch/cores" "$HOME/.config/retroarch/cores"
  '';
}
