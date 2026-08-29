{
  description = "Попробуем всё подряд, пока не заработает!";

  # ========== Входные данные (inputs) ==========
  inputs = {                                                                                               # Здесь перечисляются все внешние зависимости (flake-репозитории)
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";                                                      # Стабильный канал Nixpkgs
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";                                          # Нестабильный канал Nixpkgs (последние обновления)

    nix-cachyos-kernel = {                                                                                 # Ядро CachyOS
      url = "github:xddxdd/nix-cachyos-kernel/release";
      inputs.nixpkgs.follows = "nixpkgs";                                                                  # Зависимости используют основной nixpkgs
    };

    nur = {                                                                                                # Подключить NUR (Nix User Repository) репозиторий пользовательских пакетов
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";                                                                  # Зависимости используют основной nixpkgs
    };

    flake-parts = {                                                                                        # Flake-parts — фреймворк для модульной организации flake
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";                                                              # Зависимости используют основной nixpkgs
    };

    blender-cuda = {                                                                                       # Бинарная сборка Blender с поддержкой cuda
      url = "github:adithyagenie/blender-cuda-nixos";
      inputs.nixpkgs.follows = "nixpkgs";                                                                  # Зависимости используют основной nixpkgs
    };

#    davinci = {
#      url = "git+https://git.voidarc.co.uk/voidarc/nixos.davinci";
#      inputs.nixpkgs.follows = "nixpkgs";
#    };

    stylix = {                                                                                             # Единая настройка тем
      url = "github:nix-community/stylix/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";                                                                  # Зависимости используют основной nixpkgs
    };

    apple-fonts = {                                                                                        # Шрифты Apple
      url = "github:Lyndeno/apple-fonts.nix";
      inputs.nixpkgs.follows = "nixpkgs";                                                                  # Зависимости используют основной nixpkgs
    };

    import-tree.url = "github:vic/import-tree";                                                            # Утилита для рекурсивного импорта файлов
    comfyui-nix.url = "github:utensils/comfyui-nix";                                                       # Flake для ComfyUI
    nixpkgs-krita-25-11.url = "github:NixOS/nixpkgs/b77b3de8775677f84492abe84635f87b0e153f0f";             # Фиксированная версия nixpkgs для Krita (новая версия пока не работает с ComfyUI)
    nixpkgs-minion-25-11.url = "github:NixOS/nixpkgs/b77b3de8775677f84492abe84635f87b0e153f0f"; # TEMP

 #   fufexan/nix-gaming nickm8/nix-gaming TophC7/play.nix
  };

  # ========== Выходные данные (outputs) ==========
  outputs = inputs@{ nixpkgs, nixpkgs-unstable, nur, nix-cachyos-kernel, flake-parts, stylix, blender-cuda, comfyui-nix, nixpkgs-krita-25-11, nixpkgs-minion-25-11, ... }: # Функция, которая принимает все входы и возвращает результаты сборки
    let
      pkgsUnstable = import nixpkgs-unstable {                                                             # Создаём экземпляр нестабильного nixpkgs (для свежих пакетов)
        localSystem = "x86_64-linux";                                                                      # Новый синтаксис с атрибутом localSystem вместо устаревшего `system`
        config.allowUnfree = true;                                                                         # Разрешает установку пакетов с несвободными лицензиями
      };

      pkgsMinion = import nixpkgs-minion-25-11 { # TEMP
        localSystem = "x86_64-linux"; # TEMP
        config.allowUnfree = true; # TEMP
      }; # TEMP

      pkgsWithOverlay = import nixpkgs {                                                                   # Создаём экземпляр nixpkgs с оверлеем (кастомные пакеты)
        localSystem = "x86_64-linux";                                                                      # Здесь также используем localSystem
        config.allowUnfree = true;                                                                         # Разрешает установку пакетов с несвободными лицензиями
        overlays = [
          (import ./pkgs/overlays.nix { pkgs-unstable = pkgsUnstable; pkgs-minion = pkgsMinion; })         # Подключаем оверлей с моими пакетами (my-packages)
          comfyui-nix.overlays.default                                                                     # Оверлей ComfyUI для добавления comfy-ui-cuda
          nix-cachyos-kernel.overlays.default                                                              # Оверлей ядра CachyOS (добавляет ядра linux-cachyos и др.)
          nix-cachyos-kernel.overlays.pinned                                                               # Оверлей фиксирует версию nixpkgs на ту, которая использовалась при сборке бинарного кэша для ядер CachyOS
          nur.overlays.default                                                                             # Теперь все пакеты из NUR доступны как pkgs.nur.repos.<пользователь>.<пакет>
        ];
      };

      myLib = import ./mylib.nix;                                                                          # Импорт моего файла библиотеки с общими переменными
    in

    flake-parts.lib.mkFlake { inherit inputs; } {                                                          # Используем flake-parts для построения flake
      systems = [ "x86_64-linux" ];                                                                        # Целевая архитектура (один компьютер x86_64)
      imports = [ ];                                                                                       # Список дополнительных модулей flake-parts (пока пуст)

      # Основное содержимое флейка - системные и пользовательские конфигурации, оверлеи, пакеты
      flake = {
        nixosConfigurations.Lucerno-PC = nixpkgs.lib.nixosSystem {                                         # Системная конфигурация NixOS (для пересборки всей ОС)
          system = "x86_64-linux";                                                                         # Архитектура системы. Для nixosSystem ВСЁ ЕЩЁ используется параметр `system` (требование API NixOS)
          specialArgs = {                                                                                  # Дополнительные аргументы, передаваемые во все модули
            inherit myLib;                                                                                 # Мои общие переменные
            inherit inputs;                                                                                # Все входы (flake-зависимости)
            inherit blender-cuda;                                                                          # Flake с Blender+CUDA для передачи в пакеты
            inherit nixpkgs-krita-25-11;                                                                   # Фиксированный nixpkgs для Krita
            pkgs-unstable = pkgsUnstable;                                                                  # Нестабильные пакеты для использования в модулях
            import-tree = inputs.import-tree;                                                              # Утилита для рекурсивного импорта
            pkgs-minion = pkgsMinion; # TEMP
          };

          modules = [                                                                                      # Список модулей, из которых собирается система
            inputs.stylix.nixosModules.stylix                                                              # Модуль стилизации (stylix)
            ({ config, pkgs, lib, nixpkgs-krita-25-11, ... }: {                                            # Переопределяем krita из фиксированного набора пакетов
              nixpkgs.overlays = [
                (final: prev: {
                krita = nixpkgs-krita-25-11.legacyPackages.${final.stdenv.hostPlatform.system}.krita;      # Берём krita из фиксированной версии
                })
              ];
            })
            { nixpkgs.pkgs = pkgsWithOverlay; }                                                            # Переопределяем pkgs для всей системы (с оверлеем)
            (inputs.import-tree ./modules)                                                                 # Основной модуль config nixos. Рекурсивно импортируем все модули из папки modules/nixos
          ];
        };
      };

      perSystem = { config, pkgs, ... }: { };                                                              # Заглушка для будущих системно-зависимых настроек (например, для сборки пакетов под конкретную систему)
    };
}
