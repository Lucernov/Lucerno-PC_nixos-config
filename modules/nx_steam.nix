{ pkgs, pkgs-unstable, myLib, ... }:

let
  inherit (myLib) home;
  configDir = myLib.configDirName;
in

{
  # ========== Настройки модуля Steam и игр ==========
  programs.steam = {
    enable = true;                                          # Включает поддержку Steam (устанавливает пакет, добавляет 32-битную среду)
    remotePlay.openFirewall = true;                         # Открывает порты в фаерволе для Steam Remote Play (трансляция игры на другие устройства)
    dedicatedServer.openFirewall = true;                    # Открывает порты для выделенных серверов игр (например, для Counter-Strike, Garry's Mod)
    extraCompatPackages = [ pkgs-unstable.proton-ge-bin ];  # Дополнительные совместимые пакеты (Proton-GE) для запуска Windows-игр
  };

  # Драйвер для геймпадов Xbox (Xbox One, Series X|S) – модуль ядра
  hardware.xone.enable = true;                              # Включает поддержку беспроводных геймпадов Xbox (через официальный драйвер xone)

  # ========== Правила tmpfiles для Steam ==========
  systemd.tmpfiles.rules = [
      # ---------- Симлинки для Steam и игр ----------
    "L+ ${home}/.local/share/Steam/userdata - lucerno lucerno - ${home}/${configDir}/dotfiles/config/Steam/userdata"
    "L+ ${home}/.local/share/Steam/steamapps - lucerno lucerno - /mnt/games/SteamLibrary/steamapps"
    # --- Указывает количество потоков для компиляции шейдеров в Steam ---
    "L+ ${myLib.home}/.local/share/Steam/config/steam_dev.cfg - lucerno lucerno - ${pkgs.writeText "steam_dev.cfg" ''
      unShaderBackgroundProcessingThreads 16
    ''}"
  ];

  # Модуль GameMode – оптимизация системы для игр
  programs.gamemode = {
    enable = true;                                          # Включает службу GameMode (демон, который применяет настройки производительности)
    settings = {                                            # Конфигурация GameMode (в формате INI)
      general = {
        desiredgov = "performance";                         # Переключает CPU-губернатор в режим "performance" (максимальная частота)
        reaper_freq = 5;                                    # Частота (в секундах), с которой GameMode перепроверяет, запущена ли игра
      };
    };
  };

}
