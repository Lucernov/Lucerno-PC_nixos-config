{ config, pkgs, pkgs-unstable, inputs, lib, myLib, ... }:

{
  # НАСТРОЙКИ HOME MANAGER
  #home.stateVersion = "25.11";
  home.stateVersion = myLib.channelVersion;
  home.username = "lucerno";
  home.homeDirectory = "/home/lucerno";

  home.sessionVariables = {
    VST3_PATH = "${config.home.homeDirectory}/.vst3";  # Устанавливаем переменную окружения для пользовательской папки VST3
    WINEPREFIX = "/mnt/music/wine-yabridge";
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
  programs.home-manager.enable = true;  # Включает Home Manager как системный модуль (управление пользовательским окружением)

  # ========== Пакеты, устанавливаемые простым способом ==========
  home.packages = with pkgs; [ ] ++ (with pkgs-unstable; [ ]);
}
