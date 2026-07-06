# pkgs/minion.nix
{ stdenv, minion, jre8 }:
let
  jar = "${minion}/share/minion/Minion-jfx.jar";
in
stdenv.mkDerivation {
  name = "minion-wrapped";
  installPhase = ''
    mkdir -p $out/bin
    cat > $out/bin/minion << EOF
    #!${stdenv.shell}
    export JAVA_TOOL_OPTIONS="-Dprism.lcdtext=false -Dprism.text=t2k"
    exec ${jre8}/bin/java -jar ${jar} "\$@"
    EOF
    chmod +x $out/bin/minion
  '';
}
