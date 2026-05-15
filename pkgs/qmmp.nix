# pkgs/qmmp.nix
{ writeShellScriptBin, qmmp }:
writeShellScriptBin "qmmp" ''
  export QT_QPA_PLATFORM=xcb
  exec ${qmmp}/bin/qmmp "$@"
''
