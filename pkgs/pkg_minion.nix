# pkgs/minion.nix
{ symlinkJoin, makeWrapper, minion }:
symlinkJoin {
  name = "minion-wrapped";
  paths = [ minion ];
  buildInputs = [ makeWrapper ];
  postBuild = ''
    wrapProgram $out/bin/minion \
      --set JAVA_TOOL_OPTIONS "-Dprism.lcdtext=false -Dprism.text=t2k"
  '';
}
