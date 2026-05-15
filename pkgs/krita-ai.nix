# /home/lucerno/nixos-config/pkgs/krita-ai.nix
{ pkgs, lib, fetchFromGitHub, symlinkJoin, makeWrapper }:

let
  krita-ai-plugin = fetchFromGitHub {
    owner = "Acly";
    repo = "krita-ai-diffusion";
    rev = "v1.50.0";               # актуальная версия
    sha256 = lib.fakeSha256;       # после первой сборки замените на реальный хеш
  };
in symlinkJoin {
  name = "krita-ai";
  paths = [ pkgs.krita ];
  buildInputs = [ makeWrapper ];
  postBuild = ''
    mkdir -p $out/share/krita/pykrita
    cp -r ${krita-ai-plugin}/ai_diffusion $out/share/krita/pykrita/
  '';
}
