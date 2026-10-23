{ pkgs, myLib, ... }:

let
  inherit (myLib) home;
  configDir = myLib.configDirName;
in

{
  # ========== Шрифты для Steam ==========
  programs.steam.fontPackages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    dejavu_fonts
    liberation_ttf
  ];

  # ========== Правила tmpfiles для Steam ==========
  systemd.tmpfiles.rules = [
    # ---------- Симлинки для Steam и игр ----------
    # Родительская папка ~/.local/share/Steam должна существовать — её создаёт Steam при первом запуске.
    # Так как /mnt/games настроен с neededForBoot, диск уже смонтирован к моменту выполнения tmpfiles.
    "L+ ${home}/.local/share/Steam/steamapps - ${myLib.userName} ${myLib.userName} - /mnt/games/SteamLibrary/steamapps" # Симлинк на steamapps (замена bind-mount)
    "L+ ${home}/.local/share/Steam/userdata - ${myLib.userName} ${myLib.userName} - ${home}/${configDir}/dotfiles/config/Steam/userdata" # Симлинк на userdata

    # ---------- Конфигурация Steam ----------
    # Указать количество потоков для компиляции шейдеров в Steam
    "L+ ${home}/.local/share/Steam/config/steam_dev.cfg - ${myLib.userName} ${myLib.userName} - ${pkgs.writeText "steam_dev.cfg" ''
      unShaderBackgroundProcessingThreads 16
    ''}"

    # ---------- Шрифты для загрузчика Steam ----------
    # Закрывает проблему с квадратами (тофу) в окне загрузчика
    "L+ ${home}/.local/share/fonts - ${myLib.userName} ${myLib.userName} - /run/current-system/sw/share/X11/fonts"
  ];

  # ========== Модуль GameMode ==========
  # Оптимизация системы для игр
  programs.gamemode = {
    enable = true;                                                # Включить службу GameMode (демон, который применяет настройки производительности)
    settings = {                                                  # Конфигурация GameMode (в формате INI)
      general = {
        desiredgov = "performance";                               # Переключить CPU-губернатор в режим "performance" (максимальная частота)
        reaper_freq = 5;                                          # Частота (в секундах), с которой GameMode перепроверяет, запущена ли игра
      };
    };
  };
}
