{ lib
, stdenv
, fetchurl
, autoPatchelfHook
, alsa-lib
, freetype
, libX11
, libXext
, libxcb
, libGL
, unzip
, dpkg
, versions
}:

let
  version = versions.sforzando;
in

stdenv.mkDerivation {
  pname = "sforzando";
  inherit version;

  src = fetchurl {
    url = "https://sforzando.s3.us-east-1.amazonaws.com/LINUX_plogue-sforzando_${version}_x86_64.zip";
    hash = "sha256-7ms1T9N1/50M4wgZaD9E07cSof5P9Tx35E3wNtqCqQA=";
  };

  nativeBuildInputs = [ unzip dpkg autoPatchelfHook ];

  buildInputs = [
    alsa-lib
    freetype
    libX11
    libXext
    libxcb
    libGL
    stdenv.cc.cc.lib
  ];

  unpackPhase = ''
    runHook preUnpack
    unzip $src
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    # Распаковываем ВСЕ .deb пакеты в общую папку extracted
    mkdir -p extracted
    for deb in *.deb; do
      dpkg-deb -x "$deb" extracted
    done

    # 1. Копируем opt/Plogue (объединённый от всех трёх deb)
    mkdir -p $out/opt
    cp -r extracted/opt/Plogue $out/opt/

    # 2. VST3
    mkdir -p $out/lib/vst3
    cp -r extracted/usr/lib/vst3/* $out/lib/vst3/ || true

    # 3. CLAP
    mkdir -p $out/lib/clap
    cp -r extracted/usr/lib/clap/* $out/lib/clap/ || true

    # 4. Исполняемый файл (симлинк для сохранения относительных путей)
    mkdir -p $out/bin
    chmod +x $out/opt/Plogue/sforzando/sforzando
    ln -s $out/opt/Plogue/sforzando/sforzando $out/bin/sforzando

    # 5. .desktop, иконки, документация
    mkdir -p $out/share
    cp -r extracted/usr/share/applications $out/share/
    cp -r extracted/usr/share/icons $out/share/
    cp -r extracted/usr/share/doc $out/share/

    runHook postInstall
  '';

  meta = with lib; {
    description = "Free SFZ 2.0 compliant sample player by Plogue";
    homepage = "https://www.plogue.com/products/sforzando.html";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ sourceTypes.binaryNativeCode ];
    maintainers = [ ];
  };
}
