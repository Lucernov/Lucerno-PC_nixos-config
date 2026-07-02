{ stdenv, fetchurl, lib }:

stdenv.mkDerivation {
  pname = "socialstreamninja";
  version = "0.3.128";

  src = fetchurl {
    url = "https://github.com/steveseguin/social_stream/releases/download/v0.3.128/socialstreamninja_linux_v0.3.128_x86_64.AppImage";
    hash = "sha256-IKjSPzYp7UT1EVXpJjS5+t5WF7waeUHuEvus3jd4tJo=";
  };

  dontUnpack = true;   # ← ключевое: не распаковывать src

  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/socialstreamninja
    chmod +x $out/bin/socialstreamninja
  '';

  meta = {
    description = "Управление социальными сетями (AppImage)";
    homepage = "https://socialstreamninja.com";
    license = lib.licenses.unfree;
    platforms = [ "x86_64-linux" ];
    maintainers = with lib.maintainers; [ ];
  };
}
