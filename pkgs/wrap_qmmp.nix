# pkgs/wrap_qmmp.nix
#
# Обёртка для qmmp, принудительно использующая X11-бэкенд Qt (xcb).
#
# Зачем:
#   qmmp — Qt-приложение. В сессии KDE Plasma 6 с Wayland переменная
#   QT_QPA_PLATFORM=wayland (см. environment.sessionVariables в модуле
#   nx_configuration-kde_plasma.nix). Некоторые Qt-приложения, включая
#   qmmp, под Wayland падают или рендерятся некорректно, поэтому обёртка
#   выставляет xcb явно.
#
# Используем symlinkJoin + wrapProgram:
#   • symlinkJoin — оборачивает оригинальный пакет, не пересобирая его.
#   • wrapProgram — создаёт shell-обёртку, выставляющую окружение перед
#     запуском настоящего бинарника (оригинал переименовывается в
#     .qmmp-wrapped).

{ symlinkJoin
, makeWrapper
, qmmp
}:

symlinkJoin {
  name = "qmmp-wrapped";
  paths = [ qmmp ];
  nativeBuildInputs = [ makeWrapper ];
  postBuild = ''
    wrapProgram $out/bin/qmmp --set QT_QPA_PLATFORM xcb
  '';
}
