{ myLib, ... }:
{
  environment.sessionVariables = {
    VST3_PATH = "${myLib.home}/.vst3";                                               # Устанавливаем переменную окружения для пользовательской папки VST3
    WINEPREFIX = "/mnt/music/wine-yabridge";                                         # Префикс Wine для Windows-плагинов, используемых через yabridge
  };
}
