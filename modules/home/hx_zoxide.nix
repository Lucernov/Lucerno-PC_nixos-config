{ config, pkgs, ... }:

{
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;   # добавляет eval "$(zoxide init zsh)" в .zshrc
    options = [ "--cmd cd" ];      # заменяет cd на zoxide (умная навигация)
  };
}
