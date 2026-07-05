{ symlinkJoin, makeWrapper, minion, fetchurl }:
let
  javafxVersion = "21.0.3";
  javafxModules = [ "base" "controls" "fxml" "graphics" ];
  javafxJars = builtins.listToAttrs (map (m: {
    name = m;
    value = fetchurl {
      url = "https://repo1.maven.org/maven2/org/openjfx/javafx-${m}/${javafxVersion}/javafx-${m}-${javafxVersion}.jar";
      hash = if m == "graphics" then "sha256-Em3a2XaQVhyEQAKf+FrDkRZc+9HKBkV+gRx8zOu2hoM=" else "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
    };
  }) javafxModules);
in
symlinkJoin {
  name = "minion-wrapped";
  paths = [ minion ];
  buildInputs = [ makeWrapper ];
  postBuild = ''
    mkdir -p $out/share/minion/javafx
    cp ${javafxJars.base} $out/share/minion/javafx/javafx-base.jar
    cp ${javafxJars.controls} $out/share/minion/javafx/javafx-controls.jar
    cp ${javafxJars.fxml} $out/share/minion/javafx/javafx-fxml.jar
    cp ${javafxJars.graphics} $out/share/minion/javafx/javafx-graphics.jar

    classpath=""
    for jar in $out/share/minion/javafx/*.jar $out/share/minion/lib/*.jar $out/share/minion/Minion-jfx.jar; do
      classpath="$classpath:$jar"
    done
    classpath="''${classpath#:}"

    wrapProgram $out/bin/minion \
      --set JAVA_TOOL_OPTIONS "-Dprism.lcdtext=false -Dprism.text=t2k" \
      --set CLASSPATH "$classpath"
  '';
}
