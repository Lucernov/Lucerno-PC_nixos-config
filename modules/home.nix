{ config, pkgs, pkgs-unstable, inputs, lib, ... }:

{
  # НАСТРОЙКИ HOME MANAGER
  home.username = "lucerno";
  home.homeDirectory = "/home/lucerno";
  home.sessionPath = [ "/run/wrappers/bin" ];

  home.sessionVariables = {
    VST3_PATH = "${config.home.homeDirectory}/.vst3";  # Устанавливаем переменную окружения для пользовательской папки VST3
    WINEPREFIX = "/mnt/music/wine-yabridge";
    #PATH = "$HOME/.local/bin:$PATH";
  };

  # Импорт plasma-manager
  imports = [
    inputs.plasma-manager.homeModules.plasma-manager

    ./home-packages.nix
    ./home-file.nix

    ./hx_music.nix
    ./hx_plasma.nix    # настройки KDE Plasma (горячие клавиши, обои)
    ./hx_zsh.nix
    ./hx_git.nix
    ./hx_obs.nix
    ./hx_kitty.nix
  ];

  home.stateVersion = "25.11";
  programs.home-manager.enable = true;  # Включает Home Manager как системный модуль (управление пользовательским окружением)
}
