# pkgs/minion.nix
{ symlinkJoin, makeWrapper, minion, jre8 }:
symlinkJoin {
  name = "minion-wrapped";
  paths = [ minion ];
  buildInputs = [ makeWrapper ];
  postBuild = ''
    wrapProgram $out/bin/minion \
      --set JAVA_HOME ${jre8} \
      --set PATH ${jre8}/bin:$PATH
  '';
}
