# secrets/secrets.nix
# Карта секретов для agenix.
#
# Здесь перечислены все секреты и публичные age-ключи, которыми их можно
# расшифровать. Приватный ключ лежит в ~/.config/agenix/keys.txt (локально,
# НЕ в git).
#
# Как добавить новый секрет:
#   1. Добавить строку "имя.age".publicKeys = [ admin ];
#   2. Зашифровать: cd secrets && agenix -e имя.age
#   3. Объявить в modules/nx_agenix.nix
# пример:
# ragenix -e rclone-conf.age -i ~/.config/agenix/keys.txt
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
