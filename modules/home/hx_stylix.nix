{ inputs, ... }:

{
  # Указываем Stylix использовать схему Nord
  # Мы берем её напрямую из зависимостей самого Stylix (там лежат все tinted-schemes)
  stylix.base16Scheme = "${inputs.stylix.inputs.tinted-schemes}/share/themes/nord.yaml";

  # Возвращаем прозрачность фона терминала, которую ты убрал из настроек Kitty
  # (по умолчанию Stylix делает терминал непрозрачным)
  stylix.opacity.terminal = 0.95;

  # Опционально: если хочешь, чтобы курсор тоже был от Nord (а не дефолтный)
  stylix.cursor.name = "breeze_snow"; # или любой другой установленный курсор
}
