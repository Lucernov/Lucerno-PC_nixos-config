# pkgs/minion.nix
{ symlinkJoin, makeWrapper, minion, openjfx }:
symlinkJoin {
  name = "minion-wrapped";
  paths = [ minion ];
  buildInputs = [ makeWrapper ];
  postBuild = ''
    wrapProgram $out/bin/minion \
      --add-flags "--module-path ${openjfx}/lib --add-modules javafx.controls,javafx.fxml" \
      --set JAVA_TOOL_OPTIONS "-Dprism.lcdtext=false -Dprism.text=t2k"
  '';
}
