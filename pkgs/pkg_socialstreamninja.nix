{ stdenv, lib, appimageTools, fetchurl, makeWrapper }:

let
  version = "0.3.128";
  pname = "socialstreamninja";

  src = fetchurl {
    url = "https://github.com/steveseguin/social_stream/releases/download/v${version}/socialstreamninja_linux_v${version}_x86_64.AppImage";
    hash = "sha256-2uRfHEN19X6mpsPT0ffN6aX9vKhUSOhhxBywhsKnHpE=";
  };

  # Распаковываем AppImage
  appimage = appimageTools.extract {
    inherit pname version src;
  };

in
stdenv.mkDerivation {
  inherit pname version src;

  buildInputs = [ makeWrapper ];

  buildCommand = ''
    mkdir -p $out/bin
    # Копируем все файлы из распакованного AppImage в store
    cp -r ${appimage}/* $out/
    # Создаём обёртку, которая запускает AppRun с правильным окружением
    makeWrapper $out/AppRun $out/bin/${pname}
  '';

  meta = {
    description = "Управление социальными сетями (AppImage)";
    homepage = "https://socialstreamninja.com";
    license = lib.licenses.unfree;
    platforms = [ "x86_64-linux" ];
    maintainers = with lib.maintainers; [ ];
  };
}
