{
  description = "Попробуем всё подряд, пока не заработает!";

  # ========== Входные данные (inputs) ==========
  inputs = {                                                                                               # Здесь перечисляются все внешние зависимости (flake-репозитории)
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";                                                      # Стабильный канал Nixpkgs
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

    flake-parts = {                                                                                        # Flake-parts — фреймворк для модульной организации flake
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";                                                              # Зависимости flake-parts также используют основной nixpkgs
    };

    blender-cuda = {                                                                                       # Бинарная сборка Blender с поддержкой cuda
      url = "github:adithyagenie/blender-cuda-nixos";
      inputs.nixpkgs.follows = "nixpkgs";                                                                  # Следовать за nixpkgs
    };

    stylix = {                                                                                             # Единая настройка тем
      url = "github:nix-community/stylix/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";                                                                  # Следовать за nixpkgs
    };

    apple-fonts = {                                                                                        # Шрифты Apple
      url = "github:Lyndeno/apple-fonts.nix";
      inputs.nixpkgs.follows = "nixpkgs";                                                                  # Следовать за nixpkgs
    };

    import-tree.url = "github:vic/import-tree";                                                            # Утилита для рекурсивного импорта файлов
    comfyui-nix.url = "github:utensils/comfyui-nix";                                                       # Flake для ComfyUI
    nixpkgs-krita-25-11.url = "github:NixOS/nixpkgs/b77b3de8775677f84492abe84635f87b0e153f0f";             # Фиксированная версия nixpkgs для Krita (новая версия пока не работает с ComfyUI)

    #fufexan/nix-gaming nickm8/nix-gaming TophC7/play.nix
  };

  # ========== Выходные данные (outputs) ==========
  outputs = inputs@{ nixpkgs, nixpkgs-unstable, flake-parts, home-manager, plasma-manager, comfyui-nix, nixpkgs-krita-25-11, blender-cuda, ... }:          # Функция, которая принимает все входы и возвращает результаты сборки
    let
      pkgsUnstable = import nixpkgs-unstable {                                                             # Создаём экземпляр нестабильного nixpkgs (для свежих пакетов)
        localSystem = { system = "x86_64-linux"; };                                                        # Новый синтаксис с атрибутом localSystem вместо устаревшего `system`
        config.allowUnfree = true;                                                                         # Разрешает установку пакетов с несвободными лицензиями
      };

      pkgsWithOverlay = import nixpkgs {                                                                   # Создаём экземпляр nixpkgs с оверлеем (кастомные пакеты)
        localSystem = { system = "x86_64-linux"; };                                                        # Здесь также используем localSystem
        config.allowUnfree = true;                                                                         # Разрешает установку пакетов с несвободными лицензиями
        overlays = [
          (import ./pkgs/overlays.nix { pkgs-unstable = pkgsUnstable; })                                   # Подключаем оверлей с моими пакетами (my-packages)
          comfyui-nix.overlays.default                                                                     # Оверлей ComfyUI для добавления comfy-ui-cuda
        ];
      };

      myLib = import ./mylib.nix;                                                                          # Импорт моего файла библиотеки с общими переменными
    in

    flake-parts.lib.mkFlake { inherit inputs; } {                                                          # Используем flake-parts для построения flake
      systems = [ "x86_64-linux" ];                                                                        # Целевая архитектура (один компьютер x86_64)
      imports = [ ];                                                                                       # Список дополнительных модулей flake-parts (пока пуст)

      # Основное содержимое флейка - системные конфигурации, пользовательские конфигурации, оверлеи, пакеты
      flake = {
        nixosConfigurations.Lucerno-PC = nixpkgs.lib.nixosSystem {                                         # Системная конфигурация NixOS (для пересборки всей ОС)
          system = "x86_64-linux";                                                                         # Архитектура системы. Для nixosSystem ВСЁ ЕЩЁ используется параметр `system` (требование API NixOS)
          specialArgs = {                                                                                  # Дополнительные аргументы, передаваемые во все модули
            inherit inputs;                                                                                # Все входы (flake-зависимости)
            pkgs-unstable = pkgsUnstable;                                                                  # Нестабильные пакеты для использования в модулях
            import-tree = inputs.import-tree;                                                              # Утилита для рекурсивного импорта
            inherit myLib;                                                                                 # Мои общие переменные
            nixpkgs-krita-25-11 = nixpkgs-krita-25-11;                                                     # Фиксированный nixpkgs для Krita
            inherit blender-cuda;                                                                          # Flake с Blender+CUDA для передачи в пакеты
          };

          modules = [                                                                                      # Список модулей, из которых собирается система
            ({ config, pkgs, lib, nixpkgs-krita-25-11, ... }: {                                            # Переопределяем krita из фиксированного набора пакетов
              nixpkgs.overlays = [
                (final: prev: {
                krita = nixpkgs-krita-25-11.legacyPackages.${final.stdenv.hostPlatform.system}.krita;      # Берём krita из фиксированной версии
                })
              ];
            })
            { nixpkgs.pkgs = pkgsWithOverlay; }                                                            # Переопределяем pkgs для всей системы (с оверлеем)
            (inputs.import-tree ./modules/nixos)                                                           # Основной модуль config nixos. Рекурсивно импортируем все модули из папки modules/nixos
            inputs.stylix.nixosModules.stylix                                                              # Модуль стилизации (stylix)
          ];
        };

        # Конфигурация Home-Manager отдельно (для команды home-manager switch без sudo)
        homeConfigurations.lucerno = home-manager.lib.homeManagerConfiguration {
          pkgs = pkgsWithOverlay;                                                                         # Для отдельной команды home-manager используем тот же pkgs с оверлеем
          modules = [
          (inputs.import-tree ./modules/home)                                                             # Основной модуль home-manager. Рекурсивно импортируем все модули из папки modules/home
          ];
          extraSpecialArgs = {
            inherit inputs;                                                                               # Все flake-входы доступны в модулях home-manager
            pkgs-unstable = pkgsUnstable;                                                                 # Нестабильные пакеты для home-manager
            inherit myLib;                                                                                # Мои общие переменные
          };
        };
      };

      perSystem = { config, pkgs, ... }: { };                                                             # Заглушка для будущих системно-зависимых настроек (например, для сборки пакетов под конкретную систему)
    };
}
