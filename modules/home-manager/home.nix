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
  # Импорт plasma-manager
  imports = [
    inputs.plasma-manager.homeModules.plasma-manager

    ./programs/plasma.nix    # настройки KDE Plasma (горячие клавиши, обои)
    ./programs/zsh.nix
    ./programs/gaming.nix
    ./programs/git.nix
    ./programs/obs.nix
    ./programs/kitty.nix

    ./programs/common.nix

    ./misc/desktop-files.nix
    ./music.nix
  ];

  # НАСТРОЙКИ HOME MANAGER
  home.username = "lucerno";
  home.homeDirectory = "/home/lucerno";
  home.stateVersion = "25.11";
  programs.home-manager.enable = true;

}
