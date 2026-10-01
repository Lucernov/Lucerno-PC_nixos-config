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

    stylix = {                                                                                             # Единая настройка тем
      url = "github:nix-community/stylix/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";                                                                  # Зависимости используют основной nixpkgs
    };

    apple-fonts = {                                                                                        # Шрифты Apple
      url = "github:Lyndeno/apple-fonts.nix";
      inputs.nixpkgs.follows = "nixpkgs";                                                                  # Зависимости используют основной nixpkgs
    };

    blender-cuda = {                                                                                       # Бинарная сборка Blender с поддержкой cuda
      url = "github:adithyagenie/blender-cuda-nixos";
      inputs.nixpkgs.follows = "nixpkgs";                                                                  # Зависимости используют основной nixpkgs
    };

    comfyui-nix = {                                                                                        # Flake для ComfyUI
      url = "github:utensils/comfyui-nix";
      inputs.nixpkgs.follows = "nixpkgs";                                                                  # Зависимости используют основной nixpkgs
    };

    import-tree.url = "github:vic/import-tree";                                                            # Утилита для рекурсивного импорта файлов
    nixpkgs-krita-25-11.url = "github:NixOS/nixpkgs/b77b3de8775677f84492abe84635f87b0e153f0f";             # Фиксированная версия Krita (новая версия пока не работает с ComfyUI)
    nixpkgs-minion-25-11.url = "github:NixOS/nixpkgs/b77b3de8775677f84492abe84635f87b0e153f0f";            # Фиксированная версия minion, пакет в репозитории поломан из-за изменений в Яве. Пока чинят https://github.com/NixOS/nixpkgs/pull/539572 !!! TEMP !!!

 #   fufexan/nix-gaming nickm8/nix-gaming TophC7/play.nix
  };

  # ========== Выходные данные (outputs) ==========
  outputs = inputs@{ nixpkgs, nixpkgs-unstable, nur, stylix, blender-cuda, comfyui-nix, nixpkgs-krita-25-11, nixpkgs-minion-25-11, ... }: # Функция, которая принимает все входы и возвращает результаты сборки
    let
      pkgsUnstable = import nixpkgs-unstable {                                                             # Создаём экземпляр нестабильного nixpkgs (для свежих пакетов)
        localSystem = "x86_64-linux";                                                                      # Новый синтаксис с атрибутом localSystem вместо устаревшего `system`
        config = {
          allowUnfree = true;
        };
        overlays = [
          (final: prev: {
            # ---------- ПАТЧ REAPACK (уже есть) ----------
            reaper-reapack-extension = prev.reaper-reapack-extension.overrideAttrs (old: {
              preConfigure = (old.preConfigure or "") + ''
                find src \( -name '*.cpp' -o -name '*.hpp' -o -name '*.h' \) \
                  ! -name 'api_*' \
                  -exec sed -i 's/\[=\]/[=, this]/g' {} +
              '';
            });

            # ---------- ПАТЧ SWS (GCC 16 / C++20) ----------
            reaper-sws-extension = prev.reaper-sws-extension.overrideAttrs (old: {
              preConfigure = (old.preConfigure or "") + ''
                # Убираем удалённый конструктор копирования — из-за него
                # ContextAction перестаёт быть литеральным типом, и constexpr-массив
                # g_actions[] не компилируется в C++20 (GCC 16).
                # Это ровно тот фикс, что в upstream-коммите 1eac4cb.
                sed -i '/ContextAction(const ContextAction &) = delete;/d' \
                  Breeder/BR_ContextualToolbars.h
              '';
            });
          })
        ];
      };

      pkgsMinion = import nixpkgs-minion-25-11 {                                                           # !!! TEMP !!!
        localSystem = "x86_64-linux";                                                                      # !!! TEMP !!!
        config.allowUnfree = true;                                                                         # !!! TEMP !!!
      };                                                                                                   # !!! TEMP !!!

      allOverlays = [                                                                                      # Все оверлеи здесь и переданы один раз в `nixpkgs.pkgs = pkgsWithOverlay`. Порядок применения снизу вверх
        (import ./pkgs/default.nix { pkgs-unstable = pkgsUnstable; })                                      # 1. Оверлей с моими пакетами (my-packages), ничего не переопределяет
        nur.overlays.default                                                                               # 2. Все пакеты из NUR доступны как pkgs.nur.repos.<user>.<pkg>, ничего не переопределяет
        comfyui-nix.overlays.default                                                                       # 3. Оверлей ComfyUI (comfy-ui-cuda), ничего не переопределяет
        (final: prev: {                                                                                    # 4. Фиксированные версии krita и minion ПЕРЕОПРЕДЕЛЯЕТ существующие пакеты, поэтому идёт последним
          krita = nixpkgs-krita-25-11.legacyPackages.${final.stdenv.hostPlatform.system}.krita;            #    Krita из фиксированного nixpkgs (новая версия не работает с ComfyUI)
          minion = pkgsMinion.minion;                                                                      #    Minion из фиксированного nixpkgs (в основном канале сломан)
        })
      ];

      pkgsWithOverlay = import nixpkgs {                                                                   # Создаём экземпляр nixpkgs со всеми оверлеями
        localSystem = "x86_64-linux";                                                                      # Здесь также используем localSystem
        config = { allowUnfree = true; };                                                                  # Разрешает установку пакетов с несвободными лицензиями
        overlays = allOverlays;                                                                            # Единый список оверлеев (см. выше)
      };

      myLib = import ./mylib.nix;                                                                          # Импорт моего файла библиотеки с общими переменными
    in
    {
      nixosConfigurations.Lucerno-PC = nixpkgs.lib.nixosSystem {                                           # Системная конфигурация NixOS (для пересборки всей ОС)
        system = "x86_64-linux";                                                                           # Архитектура системы. Для nixosSystem ВСЁ ЕЩЁ используется параметр `system` (требование API NixOS)
        specialArgs = {                                                                                    # Дополнительные аргументы, передаваемые во все модули
          inherit myLib;                                                                                   # Мои общие переменные
          inherit inputs;                                                                                  # Все входы (flake-зависимости)
          inherit blender-cuda;                                                                            # Flake с Blender+CUDA для передачи в пакеты
          inherit nixpkgs-krita-25-11;                                                                     # Фиксированный nixpkgs для Krita (на случай, если модулям нужен доступ к нему напрямую)
          pkgs-unstable = pkgsUnstable;                                                                    # Нестабильные пакеты для использования в модулях
          import-tree = inputs.import-tree;                                                                # Утилита для рекурсивного импорта
        };

        modules = [                                                                                        # Список модулей, из которых собирается система
          inputs.stylix.nixosModules.stylix                                                                # Модуль стилизации (stylix)
          { nixpkgs.pkgs = pkgsWithOverlay; }                                                              # Переопределяем pkgs для всей системы
          (inputs.import-tree ./modules)                                                                   # Основной модуль config nixos. Рекурсивно импортируем все модули из папки modules/nixos
        ];
      };
    };
}
