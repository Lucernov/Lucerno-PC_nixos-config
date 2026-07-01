{ pkgs, ... }:
{
  # ========== Kitty терминал ==========
  programs.kitty = {
    enable = true;                                                                # Включает генерацию конфигурации Kitty
    package = null;                                                               # Не устанавливаем Kitty через home-manager (пакет уже установлен системно)
  };

}
