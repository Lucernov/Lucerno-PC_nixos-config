{ symlinkJoin, makeWrapper, minion, openjfx }:
symlinkJoin {
  name = "minion-wrapped";
  paths = [ minion ];
  buildInputs = [ makeWrapper ];
  postBuild = ''
    # Собираем CLASSPATH из JAR-файлов JavaFX
    classpath=""
    for jar in ${openjfx}/lib/*.jar; do
      classpath="$classpath:$jar"
    done
    classpath="''${classpath#:}"

    wrapProgram $out/bin/minion \
      --set JAVA_TOOL_OPTIONS "-Dprism.lcdtext=false -Dprism.text=t2k" \
      --set CLASSPATH "$classpath"
  '';
}
