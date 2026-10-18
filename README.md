# 🎹 Lucerno-PC NixOS Configuration & Audio Packages

Персональная конфигурация NixOS, оптимизированная для аудио-продакшена и музыкального творчества. Репозиторий также экспортирует **флейк (flake)** с набором музыкальных плагинов (VST3, CLAP, LV2), которые можно использовать в любой другой NixOS-системе.

## ✨ Особенности конфигурации

*   **ОС**: NixOS (ветка 26.05), ядро `linuxPackages_zen`.
*   **Рабочий стол**: KDE Plasma 6 (Wayland), Stylix для темизации.
*   **Аудио-стек**: PipeWire с настройками низкой задержки (квантум 64/512), JACK-совместимость, SWS и ReaPack для REAPER.
*   **Железо**: Оптимизировано под Intel i5-13400F (отключены E-ядра для аудио-потоков) и NVIDIA RTX 3070.
*   **Секреты**: Управление через `agenix`.

---

## 📦 Использование музыкальных пакетов (Flake)

Репозиторий экспортирует готовый оверлей и набор пакетов `lucerno-packages`. 

### Вариант 1: Через оверлей (Рекомендуемый)

Добавьте репозиторий в `inputs` вашего `flake.nix`:

```nix
{
  inputs = {
    # ... Ваши существующие inputs (nixpkgs, home-manager и т.д.) ...

    lucerno-audio = {
      url = "github:Lucernov/Lucerno-PC_nixos-config";
      inputs.nixpkgs.follows = "nixpkgs"; # Использовать ваш nixpkgs
    };
  };

  # ... Ваши остальные outputs ...
}
```

Затем примените оверлей и используйте доступные пакеты:

```nix
{ pkgs, inputs, ... }:
{
  nixpkgs.overlays = [ inputs.lucerno-audio.overlays.default ];

  environment.systemPackages = with pkgs.lucerno-packages; [
    # 🎛 Утилиты и Секвенсоры
    music-pattern-generator # Визуальный MIDI-секвенсор
    
    # 🎹 Синтезаторы и Сэмплеры
    ostirus           # Эмуляция Access Virus TI (CLAP)
    je8086            # Эмуляция Roland JP-8000 (CLAP)
    shortcircuit-xt   # Сэмплер (CLAP)
    drumlabooh        # LV2-сэмплер ударных
    drumlabooh-multi  # LV2-сэмплер ударных многоканальный
    
    # 🎸 Гитарные процессоры и Эффекты
    satordist2        # 4-полосный сатуратор (CLAP + VST3)
    tape-echo-2       # Эмуляция Roland Space Echo
    pitchnet          # Нейросетевой питч-корректор (VST3)
  ];
}
```

### Вариант 2: Напрямую из `packages`

Если не хотите использовать оверлеи, обращайтесь к пакетам напрямую:

```nix
{ inputs, pkgs, ... }:
{
  environment.systemPackages = [
    inputs.lucerno-audio.packages.${pkgs.stdenv.hostPlatform.system}.je8086
    inputs.lucerno-audio.packages.${pkgs.stdenv.hostPlatform.system}.shortcircuit-xt
  ];
}
```

### Использование без flake (разово)

```bash
nix build 'github:Lucernov/Lucerno-PC_nixos-config#music-pattern-generator'
nix run 'github:Lucernov/Lucerno-PC_nixos-config#music-pattern-generator'
```

### Список доступных пакетов (9 шт.)

На данный момент через `packages.x86_64-linux` и оверлей экспортируются следующие аудио-пакеты:

| Категория | Пакеты |
| :--- | :--- |
| **Утилиты и Секвенсоры** | `music-pattern-generator` |
| **Синтезаторы и Сэмплеры** | `ostirus`, `je8086`, `shortcircuit-xt`, `drumlabooh`, `drumlabooh-multi` |
| **Гитарные процессоры и Эффекты** | `satordist2`, `tape-echo-2`, `pitchnet` |

*(Остальные музыкальные пакеты, такие как `sforzando`, `numa-player` и другие, будут добавлены в этот список в ближайшее время после перевода их исходников на `fetchurl` с GitHub Media).*
