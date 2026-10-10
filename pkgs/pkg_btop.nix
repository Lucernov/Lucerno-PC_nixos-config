# pkgs/pkg_btop.nix
{ symlinkJoin, makeWrapper, btop }:
symlinkJoin {
  name = "btop-wrapped";
  paths = [ btop ];
  nativeBuildInputs = [ makeWrapper ];
  postBuild = ''
    wrapProgram $out/bin/btop \
      --set LD_LIBRARY_PATH /run/opengl-driver/lib
  '';
}
