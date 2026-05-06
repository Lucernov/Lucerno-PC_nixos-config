# pkgs/minion.nix
{ pkgs, writeShellScriptBin }:
writeShellScriptBin "minion" ''
  export JAVA_TOOL_OPTIONS="-Dprism.lcdtext=false -Dprism.text=t2k"
  exec ${pkgs.minion}/bin/minion "$@"
''
