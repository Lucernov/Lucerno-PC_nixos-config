# pkgs/pkg_SuperflyDSP.nix
#
# Три VST3-плагина от SuperflyDSP: Lost Vinyls, Lost Tapes, Lost Samplers.
# Все три поставляются как ZIP-архивы с одной папкой *.vst3 внутри.
# Собираются через общий хелпер mkSuperfly, чтобы не дублировать код.

{ lib
, stdenv
, fetchurl
, unzip
, autoPatchelfHook
, alsa-lib
, freetype
, libX11
, libXext
, libxcb
, libGL
, versions
}:

let
  mkSuperfly = { pname, version, url, hash, vst3Dir, description }:
    stdenv.mkDerivation {
      inherit pname version;

      src = fetchurl { inherit url hash; };

      nativeBuildInputs = [ unzip autoPatchelfHook ];

      buildInputs = [
        alsa-lib
        freetype
        libX11
        libXext
        libxcb
        libGL
        stdenv.cc.cc.lib
      ];

      # Архивы распаковываются «как есть» в текущую папку сборки,
      # поэтому sourceRoot — это сама папка сборки.
      sourceRoot = ".";

      unpackPhase = ''
        runHook preUnpack
        unzip $src
        runHook postUnpack
      '';

      installPhase = ''
        runHook preInstall
        mkdir -p $out/lib/vst3
        cp -r "${vst3Dir}" $out/lib/vst3/
        runHook postInstall
      '';

      meta = with lib; {
        inherit description;
        homepage = "https://superflydsp.com/";
        license = licenses.unfree;
        platforms = [ "x86_64-linux" ];
        sourceProvenance = [ sourceTypes.binaryNativeCode ];
      };
    };

in
{
  lostVinyls = mkSuperfly {
    pname = "lost-vinyls";
    inherit (versions.lostVinyls) version url hash;
    vst3Dir = "Lost-Vinyls.vst3";
    description = "SuperflyDSP Lost Vinyls – эмуляция винилового проигрывателя (VST3)";
  };

  lostTapes = mkSuperfly {
    pname = "lost-tapes";
    inherit (versions.lostTapes) version url hash;
    vst3Dir = "Lost-Tapes.vst3";
    description = "SuperflyDSP Lost Tapes – эмуляция магнитофона (VST3)";
  };

  lostSamplers = mkSuperfly {
    pname = "lost-samplers";
    inherit (versions.lostSamplers) version url hash;
    vst3Dir = "Lost-Samplers.vst3";
    description = "SuperflyDSP Lost Samplers – эмуляция шумов сэмплеров (VST3)";
  };
}
