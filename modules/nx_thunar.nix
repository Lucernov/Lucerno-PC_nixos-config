# modules/hx_thunar.nix
{ config, pkgs, lib, ... }:

{
  programs.thunar.enable = true;
  programs.thunar.plugins = with pkgs.xfce; [
    thunar-archive-plugin                       # контекстное меню для архивов
    thunar-volman                               # автоматическое монтирование USB‑накопителей
    thunar-vcs-plugin                           # поддержка Git и Subversion
  ];

  # Если понадобится корзина, сетевые папки и миниатюры,
  # раскомментируйте следующие строки:
  # services.gvfs.enable = true;
  # services.tumbler.enable = true;
  # programs.xfconf.enable = true;


  # xfce.thunar-dropbox-plugin # для пользователей Dropbox
}
