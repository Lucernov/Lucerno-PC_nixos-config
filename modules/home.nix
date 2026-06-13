{ config, pkgs, pkgs-unstable, inputs, lib, myLib, ... }:

{
  # НАСТРОЙКИ HOME MANAGER
  home.stateVersion = myLib.channelVersion;            # Версия NixOS, на которой были созданы настройки home-manager. Используется для миграции конфигурации
  home.username = "lucerno";                           # Имя пользователя, для которого применяется конфигурация
  home.homeDirectory = "/home/lucerno";                # Домашняя директория пользователя (должна совпадать с реальной)

  home.sessionVariables = {
    VST3_PATH = "${config.home.homeDirectory}/.vst3";  # Устанавливаем переменную окружения для пользовательской папки VST3
    WINEPREFIX = "/mnt/music/wine-yabridge";           # Префикс Wine для Windows-плагинов, используемых через yabridge
  };

  # Импорт plasma-manager
  imports = [
    ./home-file.nix

    ./hx_git.nix
    ./hx_kitty.nix
    ./hx_music.nix
    ./hx_plasma.nix
    ./hx_zsh.nix
    ./hx_rclone.nix
    ./hx_comfyui.nix
  ];

  # ========== Включение модулей программ (через home-manager) ==========
  # Эти модули не только устанавливают пакеты, но и позволяют централизованно настраивать их через атрибуты (например, programs.btop.settings).
  programs.home-manager.enable = true;                 # Включает Home Manager как системный модуль (управление пользовательским окружением)

  # ========== Пакеты, устанавливаемые простым способом ==========
  home.packages = with pkgs; [ ] ++ (with pkgs-unstable; [ ]);
}
