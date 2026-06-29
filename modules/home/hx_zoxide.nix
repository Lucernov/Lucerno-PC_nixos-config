{ config, pkgs, ... }:

{
  programs.zoxide = {
    enable = true;
    enableFzfIntegration = true;    # Ctrl+T для интерактивного поиска (требует fzf)
    enableZshIntegration = true;    # Заменить стандартную команду cd на z
    options = [ "--cmd cd" ];       # если хотите, чтобы zoxide перехватывал "cd"
  };
}
