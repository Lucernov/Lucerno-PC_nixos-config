#nixos-config/
#├── flake.nix                     # точка входа для Nix
#└── modules/
#    ├── home-manager/             # все модули для home-manager
#    │   ├── programs/             # ⭐ модули для НАСТРОЙКИ ПРОГРАММ
#    │   │   ├── zsh.nix
#    │   │   ├── git.nix
#    │   │   ├── kitty.nix
#    │   │   ├── reaper.nix        # здесь всё, что конфигурится через home-manager
#    │   │   └── gaming.nix        # lutris, heroic и т.д.
#    │   ├── services/             # ⭐ модули для ФОНОВЫХ СЕРВИСОВ ПОЛЬЗОВАТЕЛЯ
#    │   │   └── kde-no-file-limit.nix  # systemd сервисы (тот самый fix)
#    │   ├── misc/                 # ⭐ модули для РАЗНОГО
#    │   │   └── desktop-files.nix      # XDG, автозапуск, user-dirs
#    │   ├── music.nix             # "Дикий" модуль, который лежит прямо в папке home-manager
#    │   └── home.nix              # Корневой модуль, который всё это импортирует
#    └── nixos/ ...                # системные модули

{ config, pkgs, pkgs-unstable, inputs, lib, ... }:

{
  # НАСТРОЙКИ HOME MANAGER
  home.username = "lucerno";
  home.homeDirectory = "/home/lucerno";

  home.sessionVariables = {
    VST3_PATH = "${config.home.homeDirectory}/.vst3";  # Устанавливаем переменную окружения для пользовательской папки VST3
    WINEPREFIX = "/mnt/music/wine-yabridge";
  };

  # Импорт plasma-manager
  imports = [
    inputs.plasma-manager.homeModules.plasma-manager

    ./home-manager/programs/plasma.nix    # настройки KDE Plasma (горячие клавиши, обои)
    ./home-manager/programs/zsh.nix
    ./home-manager/programs/gaming.nix
    ./home-manager/programs/git.nix
    ./home-manager/programs/obs.nix
    ./home-manager/programs/kitty.nix

    ./home-manager/programs/home-packages.nix
    ./home-manager/misc/home-file.nix
    ./home-manager/music.nix
  ];

  home.stateVersion = "25.11";
  programs.home-manager.enable = true;  # Включает Home Manager как системный модуль (управление пользовательским окружением)
}
