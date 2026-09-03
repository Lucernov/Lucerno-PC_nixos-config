{
  wallpaperPath = ./dotfiles/wallpapers/Velo_02.png;
  userName = "lucerno";
  home = "/home/lucerno";
  hostName = "Lucerno-PC";
  channelVersion = "26.05";
  configDirName = "nixos-config";                       # не забывать также обновить имя BTRFS-подтома, иначе точка монтирования не найдётся !!!

  # --------------------------------------------------------------------------------------------------------------------------------------------
  all.autoUpdateSession = false; # переключчить на true при полной переустановке
}
