{ pkgs, ... }:
  # ПОДМЕНА ФОНА SDDM
  # файл theme.conf.user внутри темы breeze. SDDM читает этот файл и применяет настройки, не затрагивая оригинальные файлы темы.
  # Параметр background указывает на пакет mySddmBackground
{
  environment.systemPackages = [
    (pkgs.writeTextDir "share/sddm/themes/breeze/theme.conf.user" ''
      [General]
      background=${pkgs.copyPathToStore (toString ../../../dotfiles/wallpapers/Velo_01.JPG)}
    '')
  ];
}

