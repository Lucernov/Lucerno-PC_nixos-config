# pkgs/qmmp.nix
{ symlinkJoin, makeWrapper, qmmp }:
symlinkJoin {
  name = "qmmp-wrapped";
  paths = [ qmmp ];
  buildInputs = [ makeWrapper ];
  postBuild = ''
    wrapProgram $out/bin/qmmp --set QT_QPA_PLATFORM xcb
  '';
}
