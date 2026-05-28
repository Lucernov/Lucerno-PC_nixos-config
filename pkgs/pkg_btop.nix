# pkgs/btop.nix
{ symlinkJoin, makeWrapper, btop }:
symlinkJoin {
  name = "btop-wrapped";
  paths = [ btop ];
  buildInputs = [ makeWrapper ];
  postBuild = ''
    wrapProgram $out/bin/btop \
      --set LD_LIBRARY_PATH /run/opengl-driver/lib
  '';
}
