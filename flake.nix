{
  description = "Моя конфигурация NixOS для домашнего ПК";

  # ========== ВХОДНЫЕ ДАННЫЕ (inputs) ==========
  inputs = {                                                              # Здесь перечисляются внешние зависимости — flake-репозитории, которые будут использованы при сборке.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";                     # Стабильный канал Nixpkgs (NixOS 25.11). Из него будут браться основные пакеты и модули.
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";         # Нестабильный канал Nixpkgs (последние обновления). Используется для пакетов, которым нужны свежие версии.

    home-manager = {                                                      # Home Manager — управление пользовательским окружением.
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";                                 # Указываем, что home-manager должен использовать тот же экземпляр nixpkgs, что и основной. Это гарантирует единую версию пакетов.
    };

    plasma-manager = {                                                    # Plasma Manager — управление настройками KDE Plasma через Home Manager
      url = "github:nix-community/plasma-manager/trunk";
      inputs.nixpkgs.follows = "nixpkgs";                                 # Аналогично следуем за nixpkgs и home-manager
      inputs.home-manager.follows = "home-manager";
    };

    musnix.url = "github:musnix/musnix";                                  # Musnix — набор модулей для низкой задержки звука


    #nix-citizen.url = "github:LovingMelody/nix-citizen";                 # помощник для запуска Star Citizen.
  };

  # ========== ВЫХОДНЫЕ ДАННЫЕ (outputs) ==========
  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, plasma-manager, musnix, ... }@inputs: {        # Функция, которая принимает все входы и возвращает набор результатов
    nixosConfigurations.Lucerno-PC = nixpkgs.lib.nixosSystem {            # Конфигурация всей системы (NixOS) для хоста с именем Lucerno-PC
      system = "x86_64-linux";                                            # Архитектура системы (x86_64 — стандартный ПК)
      specialArgs = {                                                     # Дополнительные аргументы, которые будут переданы во все модули
        inherit inputs;                                                   # Передаём весь набор inputs (чтобы из модулей было видно другие flake-входы)
        pkgs-unstable = import nixpkgs-unstable {                         # Создаём экземпляр нестабильного nixpkgs с разрешением проприетарных пакетов
          system = "x86_64-linux";
          config.allowUnfree = true;
        };
      };

      # Список модулей, которые будут объединены для сборки системы.
      modules = [
        ./configuration.nix                                               # Основной файл конфигурации системы
        musnix.nixosModules.musnix                                        # Включение musnix (аудио настройки)
        home-manager.nixosModules.home-manager {                          # Глобальные настройки home-manager:
          home-manager.useGlobalPkgs = true;                              # Использовать пакеты из system environment
          home-manager.useUserPackages = true;                            # Разрешить пользовательские пакеты
          home-manager.users.lucerno = import ./home.nix;                 # Пользовательская конфигурация home-manager
        }
      ];
    };

    # ========== КОНФИГУРАЦИЯ HOME-MANAGER ОТДЕЛЬНО ==========
    homeConfigurations.lucerno = home-manager.lib.homeManagerConfiguration {  # Это позволяет применять настройки пользователя без прав root (команда home-manager switch)
      pkgs = nixpkgs.legacyPackages.x86_64-linux;                             # Стабильный nixpkgs — основа для пакетов пользователя
      modules = [ ./home.nix ];                                               # Модули home-manager — только ./home.nix (и возможно другие)
      extraSpecialArgs = {                                                    # Дополнительные аргументы, аналогичные системной сборке
        inherit inputs;
        pkgs-unstable = nixpkgs-unstable.legacyPackages.x86_64-linux;         # Здесь используем уже готовый набор пакетов из нестабильного канала
      };
    };
  };
}
