# secrets/secrets.nix
# Карта секретов для agenix.
#
# Здесь перечислены все секреты и публичные age-ключи, которыми их можно
# расшифровать. Приватный ключ лежит в ~/.config/agenix/keys.txt (локально,
# НЕ в git).
#
# Как добавить новый секрет:
#   1. Добавить строку "имя.age".publicKeys = [ admin ];
#   2. Зашифровать: ~/nixos-config/secrets && ragenix -e имя.age -i ~/.config/agenix/keys.txt
#   3. Объявить в modules/nx_agenix.nix

# Открыть существующий секрет (посмотреть/изменить)
# cd ~/nixos-config/secrets
# ragenix -e github-token.age -i ~/.config/agenix/keys.txt

# Конкретные примеры
# Сменить GitHub-токен:
# cd ~/nixos-config/secrets
# ragenix -e github-token.age -i ~/.config/agenix/keys.txt
# # Заменить содержимое на: access-tokens = github.com=ghp_НОВЫЙ_ТОКЕН
# Сменить git credentials:
# cd ~/nixos-config/secrets
# ragenix -e git-credentials.age -i ~/.config/agenix/keys.txt
# # Заменить на: https://Lucernov:НОВЫЙ_ТОКЕН@github.com

# Сменить пароль пользователя:
# # 1. Сгенерировать новый хеш
# mkpasswd -m yescrypt
# # Ввести пароль дважды, скопировать результат
#
# # 2. Обновить секрет
# cd ~/nixos-config/secrets
# ragenix -e lucerno-password.hash.age -i ~/.config/agenix/keys.txt
# # Вставить новый хеш $y$j9T$...

# Обновить rclone.conf (например, после rclone config reconnect):
# # 1. Посмотреть текущий конфиг
# cat ~/.config/rclone/rclone.conf
#
# # 2. Обновить секрет
# cd ~/nixos-config/secrets
# ragenix -e rclone-conf.age -i ~/.config/agenix/keys.txt
# # Вставить новый конфиг целиком

# Обновить AmneziaVPN.conf:
# cd ~/nixos-config/secrets
# ragenix -e amneziavpn-conf.age -i ~/.config/agenix/keys.txt
# # Вставить новый конфиг целиком

let
  # Публичный age-ключ пользователя lucerno
  admin = "age1geasjv7af2fncszc8dlxk3qx8fltg2dpnftrlk2x9pplmzadwd5s8vyywn";
in
{
  "github-token.age".publicKeys          = [ admin ];
  "git-credentials.age".publicKeys       = [ admin ];
  "lucerno-password.hash.age".publicKeys = [ admin ];
  "rclone-conf.age".publicKeys           = [ admin ];
  "amneziavpn-conf.age".publicKeys       = [ admin ];
}
