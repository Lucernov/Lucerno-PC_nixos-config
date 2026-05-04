{
  description = "Моя основная конфигурация NixOS для домашнего ПК";

  # ========== ВХОДНЫЕ ДАННЫЕ (inputs) ==========
  # Здесь перечисляются внешние зависимости — flake-репозитории, которые будут использованы при сборке.
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";                     # Стабильный канал Nixpkgs (NixOS 25.11). Из него будут браться основные пакеты и модули.
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";         # Нестабильный канал Nixpkgs (последние обновления). Используется для пакетов, которым нужны свежие версии.

    # Home Manager — управление пользовательским окружением.
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      # Указываем, что home-manager должен использовать тот же экземпляр nixpkgs,
      # что и основной (следуем за ним). Это гарантирует единую версию пакетов.
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Plasma Manager — управление настройками KDE Plasma через Home Manager.
    plasma-manager = {
      url = "github:nix-community/plasma-manager/trunk";
      # Аналогично следуем за nixpkgs и home-manager.
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    # Musnix — набор модулей для низкой задержки звука (аудиопроизводство).
    musnix.url = "github:musnix/musnix";

    # Закомментированный пример — помощник для запуска Star Citizen.
    # #nix-citizen.url = "github:LovingMelody/nix-citizen";
  };

  # ========== ВЫХОДНЫЕ ДАННЫЕ (outputs) ==========
  # Функция, которая принимает все входы и возвращает набор результатов.
  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, plasma-manager, musnix, ... }@inputs: {
    # Конфигурация всей системы (NixOS) для хоста с именем Lucerno-PC.
    nixosConfigurations.Lucerno-PC = nixpkgs.lib.nixosSystem {
      # Архитектура системы (x86_64 — стандартный ПК).
      system = "x86_64-linux";

      # Дополнительные аргументы, которые будут переданы во все модули.
      specialArgs = {
        # Передаём весь набор inputs (чтобы из модулей было видно другие flake-входы).
        inherit inputs;
        # Создаём экземпляр нестабильного nixpkgs с разрешением проприетарных пакетов.
        pkgs-unstable = import nixpkgs-unstable {
          system = "x86_64-linux";
          config.allowUnfree = true;
        };
      };

      # Список модулей, которые будут объединены для сборки системы.
      modules = [
        ./configuration.nix                  # Основной файл конфигурации системы.
        musnix.nixosModules.musnix          # Включение musnix (аудио настройки).
        home-manager.nixosModules.home-manager {
          # Глобальные настройки home-manager:
          home-manager.useGlobalPkgs = true;   # Использовать пакеты из system environment.
          home-manager.useUserPackages = true; # Разрешить пользовательские пакеты.
          # Пользовательская конфигурация home-manager (для пользователя lucerno).
          home-manager.users.lucerno = import ./home.nix;
          # Дополнительные аргументы специально для home-manager.
          # (Повторяем pkgs-unstable, хотя он уже передан выше — можно было опустить, но так безопаснее)
          home-manager.extraSpecialArgs = {
            inherit inputs;
            pkgs-unstable = import nixpkgs-unstable {
              system = "x86_64-linux";
              config.allowUnfree = true;
            };
          };
        }
      ];
    };

    # ========== КОНФИГУРАЦИЯ HOME-MANAGER ОТДЕЛЬНО ==========
    # Это позволяет применять настройки пользователя без прав root (команда home-manager switch).
    homeConfigurations.lucerno = home-manager.lib.homeManagerConfiguration {
      # Стабильный nixpkgs — основа для пакетов пользователя.
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      # Модули home-manager — только ./home.nix (и возможно другие).
      modules = [ ./home.nix ];
      # Дополнительные аргументы, аналогичные системной сборке.
      extraSpecialArgs = {
        inherit inputs;
        # Здесь используем уже готовый набор пакетов из нестабильного канала.
        pkgs-unstable = nixpkgs-unstable.legacyPackages.x86_64-linux;
      };
    };
  };
}
