# modules/nx_agenix.nix
# Управление секретами через agenix.
#
# При активации системы agenix расшифровывает секреты из secrets/*.age
# и кладёт их в /run/agenix/<имя> (tmpfs, доступно только указанному owner).
#
# Использование в других модулях:
#   config.age.secrets."имя".path   →   /run/agenix/имя
{ myLib, ... }:

{
  age = {
    # Приватный ключ для расшифровки (локально, не в git)
    identityPaths = [ "/home/${myLib.userName}/.config/agenix/keys.txt" ];

    secrets = {
      # GitHub-токен (используется в nx_git.nix → nix.conf)
      "github-token" = {
        file  = ../secrets/github-token.age;
        owner = myLib.userName;
        mode  = "0400";
      };

      # Git credentials (используется в nx_git.nix → ~/.git-credentials)
      "git-credentials" = {
        file  = ../secrets/git-credentials.age;
        owner = myLib.userName;
        mode  = "0400";
      };

      # Хеш пароля пользователя (используется в default.nix → hashedPasswordFile)
      "lucerno-password.hash" = {
        file  = ../secrets/lucerno-password.hash.age;
        owner = "root";
        group = "root";
        mode  = "0400";
      };

      # Конфиг rclone (используется в nx_rclone.nix)
      "rclone-conf" = {
        file  = ../secrets/rclone-conf.age;
        owner = myLib.userName;
        mode  = "0400";
      };

      # Конфиг AmneziaVPN (используется в links.nix или kde plasma)
      "amneziavpn-conf" = {
        file  = ../secrets/amneziavpn-conf.age;
        owner = myLib.userName;
        mode  = "0400";
      };
    };
  };
}

