{ pkgs, myLib, ... }:

let
  inherit (myLib) home;
  configDir = myLib.configDirName;
in

{
  # ========== Правила tmpfiles для Steam ==========
  systemd.tmpfiles.rules = [
    # ---------- Симлинки для Steam и игр ----------
    "L+ ${home}/.local/share/Steam/userdata - lucerno lucerno - ${home}/${configDir}/dotfiles/config/Steam/userdata"
    #"L+ ${home}/.local/share/Steam/steamapps - lucerno lucerno - /mnt/games/SteamLibrary/steamapps"
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
