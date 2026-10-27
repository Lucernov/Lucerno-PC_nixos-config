let
  # Переменные вынесены наружу
  userName = "lucerno";
  home = "/home/lucerno";
in
{
  # Значения
  inherit userName home;
  wallpaperPath = ./dotfiles/wallpapers/Velo_02.png;
  hostName = "Lucerno-PC";
  configDirName = "nixos-config";

  # Хелперы теперь видят переменные из let-блока
  mkDir = path: "d ${path} 0755 ${userName} ${userName} -";                         # Создать директорию
  mkLink = path: target: "L+ ${path} - ${userName} ${userName} - ${target}";        # Создать симлинк
  mkLinkExec = path: target: "L+ ${path} 0755 ${userName} ${userName} - ${target}"; # Создать исполняемый симлинк (0755)

  # Значения, которые меняются ТОЛЬКО при переустановке с нуля
  stateVersion = "26.05";                                                           # Маркер формата данных, менять только при ПОЛНОЙ переустановке системы. Откат назад ОПАСЕН, вперёд — не рекомендуется
  all.autoUpdateSession = false;                                                    # Переключчить на true при полной переустановке
}
