# pkgs/pkg_Mulhacen.nix
#
# Mulhacen — пятиполосный сустейнер от Node97 Audio с NAM + IR (CLAP).
# Альтернатива плагину Parallax.
#
# Устанавливается только CLAP-версия: VST3 и LV2 дублируют то же самое.
#
# ВАЖНО про factory-ресурсы:
#   Плагин 0.15.0 ищет заводские IRS-импульсы и .nam-модели в
#   $XDG_DATA_HOME/Mulhacen/factory/{irs,models}
#   Поэтому factory/ кладём под $out/share/Mulhacen/ и пробрасываем
#   симлинком через systemd.tmpfiles.rules в ~/.local/share/Mulhacen/factory
#   (см. modules/nx_audio.nix).

{ lib
, stdenv
, autoPatchelfHook
, curl
, libGL
, libX11
, libXcursor
, libXext
, libXrandr
, xz
}:

stdenv.mkDerivation {
  pname = "mulhacen-clap";
  version = "0.15.0";

  src        = ../dotfiles/repo/Mulhacen-0.15.0.clap.xz;
  factorySrc = ../dotfiles/repo/Mulhacen-0.15.0-factory.tar.xz;

  nativeBuildInputs = [ autoPatchelfHook xz ];

  buildInputs = [
    curl
    libGL
    libX11
    libXcursor
    libXext
    libXrandr
    stdenv.cc.cc.lib
  ];

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    # Сам плагин — в стандартный CLAP-каталог
    mkdir -p $out/lib/clap
    xz -d -c $src > $out/lib/clap/Mulhacen.clap

    # Factory-данные (IRS-импульсы + .nam-модели)
    mkdir -p $out/share/Mulhacen
    tar -xf $factorySrc -C $out/share/Mulhacen/

    # Fail-safe: если архив однажды переупакуют неверно (например, положат
    # верхним уровнем Mulhacen.vst3/factory/ вместо factory/), сборка
    # упадёт с явной ошибкой вместо молча битого симлинка из tmpfiles.
    if [ ! -d "$out/share/Mulhacen/factory/irs" ]; then
      echo "ERROR: factorySrc распаковался не в factory/ — проверьте структуру архива"
      ls -la "$out/share/Mulhacen/"
      exit 1
    fi

    runHook postInstall
  '';

  meta = with lib; {
    description = "Mulhacen — 5-band sustainer from Node97 Audio (NAM + IR, CLAP)";
    homepage = "https://node97.com/";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ sourceTypes.binaryNativeCode ];
  };
}
