# 🎹 Lucerno-PC NixOS Configuration & Audio Packages

Персональная конфигурация NixOS, оптимизированная для музыкального творчества. Репозиторий также экспортирует **флейк (flake)** с набором музыкальных плагинов (VST3, CLAP, LV2), которые можно использовать в любой другой NixOS-системе

## ✨ Особенности конфигурации

*   **ОС**: NixOS (ветка 26.05), ядро `linuxPackages_zen`
*   **Рабочий стол**: KDE Plasma 6 (Wayland)
*   **Аудио-стек**: PipeWire, REAPER
*   **Железо**: Оптимизировано под Intel i5-13400F (отключены E-ядра для аудио-потоков) и NVIDIA RTX 3070

---

## 📦 Использование музыкальных пакетов (Flake)

Репозиторий экспортирует готовый оверлей и набор пакетов `lucerno-packages`

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

### Вариант 1: Через оверлей

```nix
{ pkgs, inputs, ... }:
{
  nixpkgs.overlays = [ inputs.lucerno-audio.overlays.default ];

  environment.systemPackages = with pkgs.lucerno-packages; [
    # 🎛 Утилиты и Секвенсоры
    music-pattern-generator # Визуальный MIDI-секвенсор
    
    # 🎹 Синтезаторы и Сэмплеры
    ostirus           # Эмуляция Access Virus TI (CLAP) !!! ДЛЯ РАБОТЫ ТРЕБУЕТСЯ ОРИГИНАЛЬНЫЙ BIOS !!! ЕГО ВАМ НАДО НАЙТИ САМОСТОЯТЕЛЬНО !!! Т.е. имеется в виду, что надо получить биос из своего железного синтезатора, разумеется
    je8086            # Эмуляция Roland JP-8000 (CLAP) !!! ДЛЯ РАБОТЫ ТРЕБУЕТСЯ ОРИГИНАЛЬНЫЙ BIOS !!! ЕГО ВАМ НАДО НАЙТИ САМОСТОЯТЕЛЬНО !!! Т.е. имеется в виду, что надо получить биос из своего железного синтезатора, разумеется
    shortcircuit-xt   # Сэмплер (CLAP)
    drumlabooh        # LV2-сэмплер ударных                   https://github.com/psemiletov/drumlabooh
    drumlabooh-multi  # LV2-сэмплер ударных многоканальный    https://github.com/psemiletov/drumlabooh
    orchestools       # Набор оркестровых инструментов (VST3) https://musictop69.wixsite.com/orchestools/orchestools-two (сэмплы скачивать тут)
    ot-piano-s        # Пианино (VST2)                        https://musictop69.wixsite.com/orchestools (сэмплы скачивать тут)
    
    # 🎸 Гитарные процессоры и Эффекты
    satordist2        # 4-полосный сатуратор (CLAP + VST3)
    tape-echo-2       # Эмуляция Roland Space Echo
    pitchnet          # Нейросетевой питч-корректор (VST3)
    air-g-plugins     # Коллекция педалей и эффектов (VST3)
    relic-clap        # Набор компрессоров и эквалайзеров (CLAP)
  ];
}
```

### Вариант 2: Напрямую из `packages`

```nix
{ inputs, pkgs, ... }:
{
  environment.systemPackages = [
    # 🎛 Утилиты и Секвенсоры
    inputs.lucerno-audio.packages.${pkgs.stdenv.hostPlatform.system}.music-pattern-generator
    
    # 🎹 Синтезаторы и Сэмплеры
    inputs.lucerno-audio.packages.${pkgs.stdenv.hostPlatform.system}.ostirus
    inputs.lucerno-audio.packages.${pkgs.stdenv.hostPlatform.system}.je8086
    inputs.lucerno-audio.packages.${pkgs.stdenv.hostPlatform.system}.shortcircuit-xt
    inputs.lucerno-audio.packages.${pkgs.stdenv.hostPlatform.system}.drumlabooh
    inputs.lucerno-audio.packages.${pkgs.stdenv.hostPlatform.system}.drumlabooh-multi
    inputs.lucerno-audio.packages.${pkgs.stdenv.hostPlatform.system}.orchestools
    inputs.lucerno-audio.packages.${pkgs.stdenv.hostPlatform.system}.ot-piano-s
    
    # 🎸 Гитарные и прочие Эффекты
    inputs.lucerno-audio.packages.${pkgs.stdenv.hostPlatform.system}.satordist2
    inputs.lucerno-audio.packages.${pkgs.stdenv.hostPlatform.system}.tape-echo-2
    inputs.lucerno-audio.packages.${pkgs.stdenv.hostPlatform.system}.pitchnet
    inputs.lucerno-audio.packages.${pkgs.stdenv.hostPlatform.system}.air-g-plugins
    inputs.lucerno-audio.packages.${pkgs.stdenv.hostPlatform.system}.relic-clap
  ];
}
```

### Пример использования без flake (разово)

```bash
nix build 'github:Lucernov/Lucerno-PC_nixos-config#music-pattern-generator'
nix run 'github:Lucernov/Lucerno-PC_nixos-config#music-pattern-generator'
```

---

### Пути, по которым NixOS раскладывает музыкальные плагины

| Формат | Системный путь (для пакетов NixOS) | Пользовательский путь (для ручной установки) |
| :--- | :--- | :--- |
| **CLAP** | `/run/current-system/sw/lib/clap` | `~/.clap` |
| **VST3** | `/run/current-system/sw/lib/vst3` | `~/.vst3` |
| **VST2** | `/run/current-system/sw/lib/vst` | `~/.vst` |
| **LV2** | `/run/current-system/sw/lib/lv2` | `~/.lv2` |
| **LADSPA** | `/run/current-system/sw/lib/ladspa` | `~/.ladspa` |

---

## 📝 Примечания

*   **`mulhacen-clap`**: Временно исключен из публичных пакетов. Жду, пока автор исправит плагин (подробности на [node97.com](https://node97.com/#forum) в ветке "factory presets")
*   **`Triple-Cheese`**: Не экспортируется из-за сложностей с установкой (плагин требует записи в свои же файлы в домашней директории). Реализация воспроизводимости на другой системе пока в разработке
