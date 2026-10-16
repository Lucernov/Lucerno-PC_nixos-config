# pkgs/pkg_btop.nix
#
# Обёртка для btop, добавляющая путь к библиотекам NVIDIA в LD_LIBRARY_PATH.
#
# Зачем:
#   btop умеет показывать нагрузку GPU через NVML (libnvidia-ml.so.1).
#   На NixOS библиотеки драйвера лежат в /run/opengl-driver/lib, который
#   не входит в стандартный rpath btop. Без LD_LIBRARY_PATH btop не находит
#   NVML и не показывает GPU.
#
# Используем symlinkJoin + wrapProgram:
#   • symlinkJoin — оборачивает оригинальный пакет, не пересобирая его.
#   • wrapProgram — создаёт shell-обёртку, выставляющую окружение перед
#     запуском настоящего бинарника (оригинал переименовывается в
#     .btop-wrapped).

{ symlinkJoin
, makeWrapper
, btop
}:

symlinkJoin {
  name = "btop-wrapped";
  paths = [ btop ];
  nativeBuildInputs = [ makeWrapper ];
  postBuild = ''
    wrapProgram $out/bin/btop \
      --prefix LD_LIBRARY_PATH /run/opengl-driver/lib
  '';
}
