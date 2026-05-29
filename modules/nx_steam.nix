{ pkgs-unstable, ... }:

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

  extraEnv = {
    VK_ICD_FILENAMES = "/run/opengl-driver/share/vulkan/icd.d/nvidia_icd.json";
    VK_LAYER_DISABLE = "steam_fossilize";
    PROTON_USE_NTSYNC = "1";
    PROTON_NO_ESYNC = "1";
    PROTON_NO_FSYNC = "1";
  };

}
