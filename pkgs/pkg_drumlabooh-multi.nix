{ lib
, stdenv
, fetchurl
, unzip
, autoPatchelfHook
, fontconfig
, freetype
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "drumlabooh-multi";
  version = "12.2.0";

  src = fetchurl {
    url = "https://github.com/psemiletov/drumlabooh/releases/download/${finalAttrs.version}/drumlabooh-multi.lv2.zip";
    hash = "sha256-qdZJvXsUlEmmlTwUwO/C47OXM+gwRlu2cNRFGrJDi1A=";
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
    cp -r drumlabooh-multi.lv2 $out/lib/lv2/
    runHook postInstall
  '';

  meta = with lib; {
    description = "Drumlabooh Multi – drum sampler LV2 plugin (multi-channel)";
    homepage = "https://github.com/psemiletov/drumlabooh";
    license = licenses.gpl3Plus;
    platforms = [ "x86_64-linux" ];
  };
})
