# pkgs/pkg_qmmp.nix
{ symlinkJoin, makeWrapper, qmmp }:
symlinkJoin {
  name = "qmmp-wrapped";
  paths = [ qmmp ];
  nativeBuildInputs = [ makeWrapper ];
  postBuild = ''
    wrapProgram $out/bin/qmmp --set QT_QPA_PLATFORM xcb
  '';
}
