{ stdenv, lib, appimageTools, fetchurl, makeWrapper }:

let
  # Версия приложения (можно обновлять при выходе новых версий)
  version = "0.3.128";

  # URL для скачивания AppImage
  src = fetchurl {
    url = "https://github.com/steveseguin/social_stream/releases/download/v${version}/socialstreamninja_linux_v${version}_x86_64.AppImage";
    # Хеш SHA-256 файла (вычисли командой: nix-prefetch-url <URL>)
    sha256 = "sha256-16mlg0vxxb7v2bp42y8sphbmdppsp4s2dsam27sl9v996qzx5a10";
  };

in
appimageTools.wrapType2 {
  name = "socialstreamninja";
  inherit src;

  # Дополнительные зависимости, если нужны (обычно для AppImage хватает базовых)
  extraPkgs = pkgs: with pkgs; [
    # Например, если приложению нужны библиотеки, можно добавить:
    # libglvnd
    # alsa-lib
  ];

  meta = {
    description = "Управление социальными сетями";
    homepage = "https://socialstreamninja.com";
    license = lib.licenses.unfree; # или проприетарная
    platforms = [ "x86_64-linux" ];
    maintainers = with lib.maintainers; [ ];
  };
}
