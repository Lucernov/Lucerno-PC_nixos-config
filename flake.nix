{
  description = "Моя, хер пойми как работающая, прелесть";

  # ========== Входные данные (inputs) ==========
  inputs = {                                                                                               # Здесь перечисляются все внешние зависимости (flake-репозитории)
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";                                                      # Стабильный канал Nixpkgs (NixOS 26.05)
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";                                          # Нестабильный канал Nixpkgs (последние обновления)

    home-manager = {                                                                                       # Home Manager — управление пользовательским окружением
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";                                                                  # Использовать тот же nixpkgs, что и основной (единая версия)
    };

    plasma-manager = {                                                                                     # Plasma Manager — настройка KDE Plasma через Home Manager
      url = "github:nix-community/plasma-manager/trunk";
      inputs.nixpkgs.follows = "nixpkgs";                                                                  # Следовать за nixpkgs
      inputs.home-manager.follows = "home-manager";                                                        # Следовать за home-manager
    };

    stylix = {
      url = "github:nix-community/stylix/release-25.11";                                                   # Единая настройка тем
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-parts.url = "github:hercules-ci/flake-parts";                                                    # Flake-parts — фреймворк для модульной организации flake
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";                                                    # Зависимости flake-parts также используют основной nixpkgs

    import-tree.url = "github:vic/import-tree";                                                            # Утилита для рекурсивного импорта файлов (экспериментально)

#    comfyui-nix = {
#      url = "github:utensils/comfyui-nix";
#      #inputs.nixpkgs.follows = "nixpkgs";                                                                  # Чтобы не плодить лишние версии nixpkgs, скажем flake'y использовать основной канал nixpkgs
#    };

    nixpkgs-krita-25-11 = {
      url = "github:NixOS/nixpkgs/b77b3de8775677f84492abe84635f87b0e153f0f";
    };

    # fufexan/nix-gaming nickm8/nix-gaming TophC7/play.nix
  };

  # ========== Выходные данные (outputs) ==========
  outputs = inputs@{ flake-parts, nixpkgs, nixpkgs-unstable, home-manager, plasma-manager, comfyui-nix, nixpkgs-krita-25-11, ... }:          # Функция, которая принимает все входы и возвращает результаты сборки
    let
      pkgsUnstable = import nixpkgs-unstable {                                                             # Создаём экземпляр нестабильного nixpkgs (для свежих пакетов)
        system = "x86_64-linux";
        config.allowUnfree = true;
      };

      pkgsWithOverlay = import nixpkgs {                                                                   # Создаём экземпляр nixpkgs с оверлеем (кастомные пакеты)
        system = "x86_64-linux";
        config.allowUnfree = true;
        overlays = [
          (import ./pkgs/overlays.nix { pkgs-unstable = pkgsUnstable; })
          #comfyui-nix.overlays.default
        ];
      };

      myLib = import ./mylib.nix;                                                                          # Импорт моего файла библиотеки
    in

    flake-parts.lib.mkFlake { inherit inputs; } {                                                          # Используем flake-parts для построения flake
      systems = [ "x86_64-linux" ];                                                                        # Целевая архитектура (один компьютер x86_64)
      imports = [ ];                                                                                       # Список дополнительных модулей flake-parts (пока пуст)

      # Основное содержимое флейка - системные конфигурации, пользовательские конфигурации, оверлеи, пакеты
      flake = {
        nixosConfigurations.Lucerno-PC = nixpkgs.lib.nixosSystem {                                         # Системная конфигурация NixOS (для пересборки всей ОС)
          system = "x86_64-linux";                                                                         # Архитектура системы
          specialArgs = {                                                                                  # Дополнительные аргументы, передаваемые во все модули
            inherit inputs;
            pkgs-unstable = pkgsUnstable;                                                                  # Передаём нестабильные пакеты
            import-tree = inputs.import-tree;                                                              # Передаём утилиту import-tree
            inherit myLib;
            nixpkgs-krita-25-11 = nixpkgs-krita-25-11;
          };

          modules = [                                                                                      # Список модулей, из которых собирается система
            ({ config, pkgs, lib, nixpkgs-krita-25-11, ... }: {
              nixpkgs.overlays = [
                (final: prev: {
                krita = nixpkgs-krita-25-11.legacyPackages.${final.system}.krita;
                })
              ];
            })
            { nixpkgs.pkgs = pkgsWithOverlay; }                                                            # Переопределяем pkgs для всей системы (с оверлеем)
            ./modules
            inputs.stylix.nixosModules.stylix
          ];
        };

        # Конфигурация Home-Manager отдельно (для команды home-manager switch без sudo)
        homeConfigurations.lucerno = home-manager.lib.homeManagerConfiguration {
          pkgs = pkgsWithOverlay;                                                                         # Для отдельной команды home-manager используем тот же pkgs с оверлеем
          modules = [ ./modules/home.nix ];                                                               # Основной модуль home-manager
          extraSpecialArgs = {
            inherit inputs;
            pkgs-unstable = pkgsUnstable;                                                                 # Нестабильные пакеты для home-manager
            inherit myLib;
          };
        };
      };

      perSystem = { config, pkgs, ... }: { };                                                             # Системно-зависимые настройки (пока не используются)
    };
}
