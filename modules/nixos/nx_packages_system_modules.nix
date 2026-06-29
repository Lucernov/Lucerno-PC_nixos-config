# modules/nx_soft.nix
{ config, pkgs, pkgs-unstable, blender-cuda, ... }:

let
  packages = import ../packages.nix { inherit pkgs pkgs-unstable; };
  packages = import ../packages.nix { inherit pkgs pkgs-unstable blender-cuda; };
in

{
  # ========== Включение системных модулей для программ ==========
  programs.git.enable = true;                                   # Включает поддержку Git (утилита системы контроля версий)
  programs.dconf.enable = true;                                 # Включает dconf – базу данных настроек для GTK-приложений (необходим для тем, шрифтов и т.п.)
  programs.zsh.enable = true;                                   # Регистрирует Zsh как системную оболочку
  programs.vim.enable = true;                                   # Устанавливает Vim (текстовый редактор) системно
  programs.nano.enable = true;                                  # Устанавливает Nano (простой текстовый редактор) системно
  programs.htop.enable = true;                                  # Устанавливает htop (интерактивный монитор процессов) системно
  programs.amnezia-vpn.enable = true;                           # Включает сервис AmneziaVPN (VPN-клиент)
  programs.appimage = {
    enable = true;                                              # Включает поддержку запуска AppImage-файлов (бинарные образы приложений)
    binfmt = true;                                              # Эта опция автоматически настраивает загрузчик
  };
  # KDE приложения
  programs.partition-manager.enable = true;                     # Включает модуль для утилиты управления разделами диска (KDE Partition Manager)
  programs.kdeconnect.enable = true;                            # Включает интеграцию с телефоном: синхронизация уведомлений, буфера обмена, управление презентациями и т.д.


  environment.systemPackages = packages.systemPackages;         # Импорт системно установленных пакетов

}
