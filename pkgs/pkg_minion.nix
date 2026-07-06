# pkgs/minion.nix
{ pkgs, minion, jre8 }:
let
  jar = "${minion}/share/minion/Minion-jfx.jar";
in
pkgs.writeShellScriptBin "minion" ''
  export JAVA_TOOL_OPTIONS="-Dprism.lcdtext=false -Dprism.text=t2k"
  exec ${jre8}/bin/java -jar ${jar} "$@"
''
