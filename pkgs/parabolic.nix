# pkgs/parabolic.nix
{ writeShellScriptBin, parabolic }:
writeShellScriptBin "parabolic" ''
  exec ${parabolic}/bin/org.nickvision.tubeconverter "$@"
''
