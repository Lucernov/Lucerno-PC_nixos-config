{ lib
, stdenv
, fetchurl
, unzip
, autoPatchelfHook
, fontconfig
, freetype
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "drumlabooh";
  version = "13.0.0";

  src = fetchurl {
    url = "https://github.com/psemiletov/drumlabooh/releases/download/${finalAttrs.version}/drumlabooh.lv2.zip";
    hash = "sha256-qHT6Wj9eYpbMTkcPzpqVnFL+qpCyUm+rYqecW40aqSQ=";
  };

  nativeBuildInputs = [ unzip autoPatchelfHook ];

  buildInputs = [
    fontconfig
    freetype
    stdenv.cc.cc.lib
  ];

  sourceRoot = ".";

  unpackPhase = ''
    runHook preUnpack
    unzip $src
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib/lv2
    cp -r drumlabooh.lv2 $out/lib/lv2/
    runHook postInstall
  '';

  meta = with lib; {
    description = "Drumlabooh – drum sampler LV2 plugin (single-channel)";
    homepage = "https://github.com/psemiletov/drumlabooh";
    license = licenses.gpl3Plus;
    platforms = [ "x86_64-linux" ];
  };
})
