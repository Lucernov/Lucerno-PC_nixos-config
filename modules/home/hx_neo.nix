{ config, pkgs, ... }:

{
  # Устанавливаем neo (если он есть в nixpkgs)
  # home.packages = with pkgs; [ neo ];

  # Алиас для запуска neo с прозрачным фоном (через --defaultbg)
  home.shellAliases = {
    neo = "neo --defaultbg";   # Использует фон терминала (прозрачный, если включён в Kitty)
  };
}
