{
  description = "Попробуем всё подряд, пока не заработает!";

  # ========== Входные данные (inputs) ==========
  inputs = {                                                                                               # Все внешние зависимости (flake-репозитории)
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";                                                      # Стабильный канал Nixpkgs
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";                                          # Нестабильный канал Nixpkgs (последние обновления)

    nur = {                                                                                                # Подключить NUR (Nix User Repository) репозиторий пользовательских пакетов
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";                                                                  # Зависимости используют основной nixpkgs
    };

    agenix = {                                                                                             # Управление секретами (шифрование через age)
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";                                                                  # Зависимости используют основной nixpkgs
    };

    stylix = {                                                                                             # Единая настройка тем
      url = "github:nix-community/stylix/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";                                                                  # Зависимости используют основной nixpkgs
    };

    artcraft = {                                                                                           # Набор приложений Аrtcraft
      url = "github:devitek/artcraft-nixos";
      inputs.nixpkgs.follows = "nixpkgs";                                                                  # Зависимости используют основной nixpkgs
    };

    blender-cuda.url = "github:adithyagenie/blender-cuda-nixos";                                           # Бинарная сборка Blender с поддержкой cuda
    comfyui-nix.url = "github:utensils/comfyui-nix";                                                       # Flake для ComfyUI
    import-tree.url = "github:vic/import-tree";                                                            # Утилита для рекурсивного импорта файлов
    nixpkgs-pinned-25-11.url = "github:NixOS/nixpkgs/b77b3de8775677f84492abe84635f87b0e153f0f";            # Снапшот nixpkgs 25.11, нужен для krita (krita нужна 5.2.15 (Qt5) — плагины ai_diffusion и vision_tools не совместимы (Qt6))
  };

  # ========== Выходные данные (outputs) ==========
  outputs = inputs@{ nixpkgs, nixpkgs-unstable, nur, agenix, stylix, blender-cuda, comfyui-nix, artcraft, nixpkgs-pinned-25-11, ... }: # Функция, которая принимает все входы и возвращает результаты сборки
    let
      pkgsUnstable = import nixpkgs-unstable {                                                             # Создать экземпляр нестабильного nixpkgs (для свежих пакетов)
        localSystem = "x86_64-linux";                                                                      # Новый синтаксис с атрибутом localSystem вместо устаревшего `system`
        config = {
          allowUnfree = true;
        };
      };

      # Создаем оверлеи и pkgs ТОЛЬКО для сборки пакетов (outputs)
      allOverlays = [                                                                                      # Все оверлеи здесь и переданы один раз в `nixpkgs.pkgs = pkgsWithOverlay`. Порядок применения снизу вверх
        (import ./pkgs/default.nix { pkgs-unstable = pkgsUnstable; })                                      # 1. Оверлей с моими пакетами (lucerno-packages), ничего не переопределяет
        nur.overlays.default                                                                               # 2. Все пакеты из NUR доступны как pkgs.nur.repos.<user>.<pkg>, ничего не переопределяет
        comfyui-nix.overlays.default                                                                       # 3. Оверлей ComfyUI (comfy-ui-cuda), ничего не переопределяет
        (final: prev: {                                                                                    # 4. Финальные переопределения krita и minion. Идут последними, чтобы перебить всё выше
          krita  = (import nixpkgs-pinned-25-11 { localSystem = "x86_64-linux"; config.allowUnfree = true; }).krita;
          minion = final.lucerno-packages.minion;
        })
      ];

      pkgsWithOverlay = import nixpkgs {                                                                   # Создать экземпляр nixpkgs со всеми оверлеями
        localSystem = "x86_64-linux";                                                                      # Здесь также используется localSystem
        config = { allowUnfree = true; };                                                                  # Разрешаить установку пакетов с несвободными лицензиями
        overlays = allOverlays;                                                                            # Единый список оверлеев (см. выше)
      };

      myLib = import ./mylib.nix;                                                                          # Импорт моего файла библиотеки с общими переменными
    in
    {
      nixosConfigurations.Lucerno-PC = nixpkgs.lib.nixosSystem {                                           # Системная конфигурация NixOS
        specialArgs = {                                                                                    # Дополнительные аргументы, передаваемые во все модули
          inherit myLib;                                                                                   # Мои общие переменные
          inherit inputs;                                                                                  # Все входы (flake-зависимости)
          inherit blender-cuda;                                                                            # Flake с Blender+CUDA для передачи в пакеты
          pkgs-unstable = pkgsUnstable;                                                                    # Нестабильные пакеты для использования в модулях
        };

        modules = [                                                                                        # Список модулей, из которых собирается система
          inputs.stylix.nixosModules.stylix                                                                # Модуль стилизации (stylix)
          inputs.agenix.nixosModules.default                                                               # Модуль управления секретами (agenix)
          inputs.artcraft.nixosModules.default                                                             # Модуль приложений Аrtcraft
          (inputs.import-tree ./modules)                                                                   # Основной модуль config nixos. Рекурсивно импортируются все модули из папки modules/nixos
        ];
      };

      # ========== Пакеты для nix-update и nix build ==========
      packages.x86_64-linux = import ./pkgs/export.nix {
        pkgs = pkgsWithOverlay;
      };
    };
}
