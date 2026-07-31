{ lib
, stdenv
, fetchurl
, unzip
, autoPatchelfHook
}:

stdenv.mkDerivation {
  pname = "drumlabooh";
  version = "12.2.0";

  srcs = [
    (fetchurl {
      url = "https://github.com/psemiletov/drumlabooh/releases/download/12.2.0/drumlabooh.lv2.zip";
      hash = "sha256-IQ0XzIwJqGg+6FynmJBllyBIzWD3dgFfllOTEx0cMDM=";
    })
    (fetchurl {
      url = "https://github.com/psemiletov/drumlabooh/releases/download/12.2.0/drumlabooh-multi.lv2.zip";
      hash = "sha256-qdZJvXsUlEmmlTwUwO/C47OXM+gwRlu2cNRFGrJDi1A=";
    })
  ];

  sourceRoot = ".";

  nativeBuildInputs = [ unzip autoPatchelfHook ];

  # Распаковываем оба архива в текущую директорию
  unpackPhase = ''
    runHook preUnpack
    for src in $srcs; do
      unzip $src
    done
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/lv2
    cp -r drumlabooh.lv2 $out/lib/lv2/
    cp -r drumlabooh-multi.lv2 $out/lib/lv2/

    runHook postInstall
  '';

  meta = with lib; {
    description = "Drum sampler LV2 plugin with multiple drum kits";
    homepage = "https://github.com/psemiletov/drumlabooh";
    license = licenses.gpl3Plus;
    platforms = [ "x86_64-linux" ];
    maintainers = [ ];
  };
}
