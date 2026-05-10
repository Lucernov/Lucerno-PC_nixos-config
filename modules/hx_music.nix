{ pkgs, pkgs-unstable, lib, ... }:

{
  # ========== Пакеты для музыки и звука ==========
  home.packages = with pkgs; [
    yabridge                    # Мост для запуска Windows VST-плагинов в Linux (через Wine)
    yabridgectl                 # Утилита для управления yabridge (сканирование, синхронизация)
    winetricks                  # Вспомогательный скрипт для настройки Wine (установка DLL, зависимостей)
    coppwr                      # Графическая утилита для управления PipeWire (альтернатива pw-top)
    vital                       # Популярный синтезатор FM (VST-плагин)
    surge-xt                    # Синтезатор Surge XT (открытый код, мощный)
    geonkick                    # Синтезатор барабанов для создания ударных партий
    drumgizmo                   # Многоканальный сэмплер барабанов (реалистичные ударные)
    neural-amp-modeler-lv2      # Плагин LV2 для моделирования гитарных усилителей (Neural Amp Modeler)
    dragonfly-reverb            # Качественная реверберация Dragonfly (VST/LV2)
    fretboard                   # Гитаровый гриф / MIDI-инструмент (возможно, для обучения)

    wineWow64Packages.staging   # Wine с поддержкой 64 и 32 бит (staging‑патчи для аудио)
  ] ++ (with pkgs-unstable; [   # Пакеты из нестабильного канала (более свежие версии)
    reaper                      # REAPER – цифровая звуковая рабочая станция (DAW)
    reaper-sws-extension        # Расширение SWS для REAPER (дополнительные команды и автоматизация)
    reaper-reapack-extension    # Менеджер скриптов ReaPack для REAPER (установка пользовательских скриптов)
  ]);

  # ========== Активационные скрипты (выполняются при каждом переключении поколения home-manager) ==========
  # Создаёт символическую ссылку wine64 в ~/.local/bin, чтобы winetricks не ругался на отсутствие wine64
  home.activation.createWine64Link = lib.hm.dag.entryAfter ["writeBoundary"] ''
    mkdir -p $HOME/.local/bin
    ln -sf ${pkgs-unstable.wineWow64Packages.staging}/bin/wine $HOME/.local/bin/wine64
  '';

  # Создаёт каталог ~/.vst3 для пользовательских VST-плагинов (стандартная папка для VST3)
  home.activation.createVst3Dir = lib.hm.dag.entryAfter ["writeBoundary"] ''
    mkdir -p $HOME/.vst3
  '';

  # ========== Пользовательские файлы (конфигурация REAPER) ==========
  # Копирует библиотеку расширения SWS в папку UserPlugins REAPER (автоматически подгружается)
  home.file.".config/REAPER/UserPlugins/reaper_sws-x86_64.so".source = "${pkgs-unstable.reaper-sws-extension}/UserPlugins/reaper_sws-x86_64.so";
  # Копирует библиотеку расширения ReaPack в папку UserPlugins REAPER
  home.file.".config/REAPER/UserPlugins/reaper_reapack-x86_64.so".source = "${pkgs-unstable.reaper-reapack-extension}/UserPlugins/reaper_reapack-x86_64.so";
}
