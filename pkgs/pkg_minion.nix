{ symlinkJoin, makeWrapper, minion, fetchurl }:
let
  javafxVersion = "21.0.3";
  javafxModules = [ "base" "controls" "fxml" "graphics" ];
  javafxJars = builtins.listToAttrs (map (m: {
    name = "javafx-${m}";
    value = fetchurl {
      url = "https://repo1.maven.org/maven2/org/openjfx/javafx-${m}/${javafxVersion}/javafx-${m}-${javafxVersion}.jar";
      hash = "sha256-Em3a2XaQVhyEQAKf+FrDkRZc+9HKBkV+gRx8zOu2hoM=";
    };
  }) javafxModules);
in
symlinkJoin {
  name = "minion-wrapped";
  paths = [ minion ];
  buildInputs = [ makeWrapper ];
  postBuild = ''
    # Собираем JAR-файлы JavaFX в одну папку
    mkdir -p $out/share/minion/javafx
    ln -s ${javafxJars.javafx-base} $out/share/minion/javafx/javafx-base.jar
    ln -s ${javafxJars.javafx-controls} $out/share/minion/javafx/javafx-controls.jar
    ln -s ${javafxJars.javafx-fxml} $out/share/minion/javafx/javafx-fxml.jar
    ln -s ${javafxJars.javafx-graphics} $out/share/minion/javafx/javafx-graphics.jar

    wrapProgram $out/bin/minion \
      --set JAVA_TOOL_OPTIONS "-Dprism.lcdtext=false -Dprism.text=t2k" \
      --add-flags "-cp $out/share/minion/javafx/*:$out/share/minion/Minion-jfx.jar:$out/share/minion/lib/*"
  '';
}
