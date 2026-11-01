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
#
# ─────────────────────────────────────────────────────────────────────
# ОБНОВЛЕНИЕ ПРИ НОВОЙ ВЕРСИИ MULHACEN
# ─────────────────────────────────────────────────────────────────────
# Апстрим не имеет публичного API (Node97 Audio не публикует релизы
# на GitHub/GitLab), поэтому nix-update тут не применим. Архивы лежат
# в собственных GitHub Releases этого репозитория.
#
#   1. Получить новый .clap и factory-архив от автора.
#   2. Загрузить оба как ассеты в GitHub Releases:
#        https://github.com/Lucernov/Lucerno-PC_nixos-config/releases
#      (обновить тег personal-assets-<N> или создать новый)
#   3. Пересчитать хеши:
#        nix-prefetch-url "https://github.com/.../Mulhacen-<ver>.clap.xz"
#        nix hash convert --hash-algo sha256 --to sri <base32>
#        (то же для factory-архива)
#   4. Обновить version, url, hash, factoryUrl, factoryHash
#      в pkgs/versions.nix (блок mulhacen-clap).
#   5. nix build .#mulhacen-clap && local-up
#
# ─────────────────────────────────────────────────────────────────────

{ lib
, stdenv
, fetchurl
, autoPatchelfHook
, curl
, libGL
, libX11
, libXcursor
, libXext
, libXrandr
, xz
, versions
}:

let
  inherit (versions.mulhacen-clap) version url hash factoryUrl factoryHash;
in

stdenv.mkDerivation {
  pname = "mulhacen-clap";
  inherit version;

  # Берём плагин из GitHub Releases
  src = fetchurl {
    inherit url hash;
  };

  # Берём factory-ресурсы из GitHub Releases
  factorySrc = fetchurl {
    url = factoryUrl;
    hash = factoryHash;
  };

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
