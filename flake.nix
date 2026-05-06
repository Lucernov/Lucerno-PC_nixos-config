{
  description = "Моя конфигурация NixOS для домашнего ПК";

  # ========== Входные данные (inputs) ==========
  inputs = {                                                                                               # Здесь перечисляются все внешние зависимости (flake-репозитории)
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";                                                      # Стабильный канал Nixpkgs (NixOS 25.11)
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";                                          # Нестабильный канал Nixpkgs (последние обновления)

    home-manager = {                                                                                       # Home Manager — управление пользовательским окружением
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";                                                                  # Указываем, что home-manager должен использовать тот же экземпляр nixpkgs
    };

    plasma-manager = {                                                                                     # Plasma Manager — настройка KDE Plasma через Home Manager
      url = "github:nix-community/plasma-manager/trunk";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    musnix.url = "github:musnix/musnix";                                                                   # Musnix — набор модулей для низкой задержки звука

    flake-parts.url = "github:hercules-ci/flake-parts";                                                    # Flake-parts — фреймворк для модульной организации flake
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";
  };

  # ========== Выходные данные (outputs) ==========
  outputs = inputs@{ flake-parts, nixpkgs, nixpkgs-unstable, home-manager, plasma-manager, musnix, ... }:  # Функция, которая принимает все входы и возвращает результаты сборки
    let
      pkgsWithOverlay = import nixpkgs {
        system = "x86_64-linux";
        config.allowUnfree = true;
        overlays = [ (import ./overlays/default.nix) ];
      };
      pkgsUnstable = import nixpkgs-unstable {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };
    in
    flake-parts.lib.mkFlake { inherit inputs; } {                                                          # Используем flake-parts для построения flake
      systems = [ "x86_64-linux" ];                                                                        # Целевая архитектура (один компьютер x86_64)
      imports = [ ];                                                                                       # Список дополнительных модулей flake-parts (пока пуст)

      # Основное содержимое флейка - системные конфигурации, пользовательские конфигурации, оверлеи, пакеты
      flake = {
        nixosConfigurations.Lucerno-PC = nixpkgs.lib.nixosSystem {                                         # Системная конфигурация NixOS для хоста
          system = "x86_64-linux";                                                                         # Архитектура системы
          specialArgs = {                                                                                  # Дополнительные аргументы, передаваемые во все модули
            inherit inputs;
            pkgs-unstable = pkgsUnstable;
            };

          modules = [                                                                                      # Список модулей, из которых собирается система
            { nixpkgs.pkgs = pkgsWithOverlay; }
            ./modules/hosts/Lucerno-PC                                                                     # Основной модуль хоста (импортирует профили)
            musnix.nixosModules.musnix                                                                     # Модуль musnix (аудио оптимизация)
            home-manager.nixosModules.home-manager {                                                       # Home Manager, интегрированный как системный модуль
              home-manager.useGlobalPkgs = true;                                                           # Использовать глобальные пакеты
              home-manager.useUserPackages = true;                                                         # Разрешить пользовательские пакеты
              home-manager.users.lucerno = import ./modules/home-manager/home.nix;                         # Путь к конфигурации пользователя
              home-manager.extraSpecialArgs = {
                inherit inputs;
                pkgs-unstable = pkgsUnstable;
                pkgs = pkgsWithOverlay;
              };
            }
          ];
        };

        homeConfigurations.lucerno = home-manager.lib.homeManagerConfiguration {                          # Конфигурация Home-Manager отдельно (для команды home-manager switch)
          pkgs = pkgsWithOverlay;                                                                         # Для отдельной команды home-manager switch используем тот же pkgs с оверлеем
          modules = [ ./modules/home-manager/home.nix ];
          extraSpecialArgs = {
            inherit inputs;
            pkgs-unstable = nixpkgs-unstable.legacyPackages.x86_64-linux;
          };
        };
      };


      perSystem = { config, pkgs, ... }: { };                                                             # Системно-зависимые настройки (пока не используются)
    };
}
