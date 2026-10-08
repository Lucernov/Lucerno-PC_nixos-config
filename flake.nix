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
            # ---------- ПАТЧ REAPACK (GCC 16.2 / C++20) ----------
            # В GCC 16.2 предупреждение "implicit capture of 'this' via '[=]'"
            # стало ошибкой из-за -Werror в проекте. Заменяем [=] на [=, this]
            # в исходниках. Файлы api_* исключаем: там лямбды в статических
            # функциях, 'this' не существует, и [=, this] не скомпилируется.
            #
            # Патч «fail-safe»: если '[=]' больше не встречается в src/ —
            # значит апстрим починили, и мы хотим УЗНАТЬ об этом через
            # падение сборки, а не молча собирать с устаревшим патчем.
            reaper-reapack-extension = prev.reaper-reapack-extension.overrideAttrs (old: {
              preConfigure = (old.preConfigure or "") + ''
                files=$(find src \( -name '*.cpp' -o -name '*.hpp' -o -name '*.h' \) \
                          ! -name 'api_*' -exec grep -l '\[=\]' {} +)
                if [ -z "$files" ]; then
                  echo "ERROR: reapack patch — '[=]' не найден в src/"
                  echo "Скорее всего, апстрим исправил проблему. Удалите этот патч."
                  exit 1
                fi
                echo "$files" | while IFS= read -r f; do
                  sed -i 's/\[=\]/[=, this]/g' "$f"
                done
              '';
            });

            # ---------- ПАТЧ SWS (GCC 16.2 / C++20) ----------
            # GCC 16.2 отказывается считать ContextAction literal type, поэтому
            # constexpr-массив g_actions[] не инициализируется через brace-init-list.
            # Добавляем в структуру constexpr-конструктор — он делает ContextAction
            # literal type (инициализация становится вызовом конструктора, а не
            # aggregate init).
            # Создал issue - https://github.com/reaper-oss/sws/issues/2046
            #
            # Патч «fail-safe»: проверяем паттерн до замены и результат после.
            # Если апстрим починили (или переписали файл) — сборка упадёт с
            # явной ошибкой, и мы это заметим.
            reaper-sws-extension = prev.reaper-sws-extension.overrideAttrs (old: {
              preConfigure = (old.preConfigure or "") + ''
                echo "=== SWS PATCH: inserting constexpr constructor ==="
                if ! grep -q 'bool isBuiltin() const { return type == Builtin; }' \
                     Breeder/BR_ContextualToolbars.cpp; then
                  echo "ERROR: SWS patch — паттерн не найден"
                  echo "Смотрите https://github.com/reaper-oss/sws/issues/2046"
                  exit 1
                fi
                sed -i 's|bool isBuiltin() const { return type == Builtin; }|constexpr ContextAction(int i, Type t, int o, int c) : iniKey(i), type(t), openCommand(o), toggleCommand(c) {} bool isBuiltin() const { return type == Builtin; }|' \
                  Breeder/BR_ContextualToolbars.cpp
                if ! grep -q 'constexpr ContextAction(int' Breeder/BR_ContextualToolbars.cpp; then
                  echo "ERROR: SWS patch — замена не сработала"
                  exit 1
                fi
                echo "=== SWS PATCH: applied successfully ==="
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

      # ========== Пакеты для nix-update и nix build ==========
      # Экспортируем пакеты как flake outputs, чтобы их можно было обновлять
      # через `nix run github:Mic92/nix-update -- <имя> --flake`.
      # Добавляем только те пакеты, у которых version/hash заданы прямо в
      # pkg_*.nix (не через versions.nix) — иначе nix-update не найдёт их.
      # Остальные пакеты my-packages не трогаем: они не поддерживают автообновление.
      #
      # ⚠️ При добавлении нового пакета с автообновлением — не забудьте
      # добавить его и сюда, иначе `nix-update --flake <имя>` его не увидит.
      packages.x86_64-linux = {
        drumlabooh = pkgsWithOverlay.my-packages.drumlabooh;
        drumlabooh-multi = pkgsWithOverlay.my-packages.drumlabooh-multi;
        je8086 = pkgsWithOverlay.my-packages.je8086;
        ostirus = pkgsWithOverlay.my-packages.ostirus;
        pitchnet = pkgsWithOverlay.my-packages.pitchnet;
        tape-echo-2 = pkgsWithOverlay.my-packages.tape-echo-2;
      };
    };
}
