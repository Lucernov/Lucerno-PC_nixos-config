{
  # ===== Значения, которые можно менять на живой системе =====
  wallpaperPath = ./dotfiles/wallpapers/Velo_02.png;
  userName = "lucerno";
  home = "/home/lucerno";
  hostName = "Lucerno-PC";
  configDirName = "nixos-config";

  # ===== Значения, которые меняются ТОЛЬКО при переустановке с нуля =====
  stateVersion = "26.05";                            # Маркер формата данных (миграции users, postgres, nextcloud и т.п.) Менять только при переустановке. Откат назад ОПАСЕН, вперёд — не рекомендуется
  all.autoUpdateSession = false;                     # Переключчить на true при полной переустановке
}
