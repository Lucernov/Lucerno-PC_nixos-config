{ symlinkJoin, makeWrapper, minion, fetchurl }:
let
  javafxVersion = "21.0.3";
  javafxModules = [ "base" "controls" "fxml" "graphics" ];

  # Функция для получения jar-файла с нужным хешем
  fetchJar = module: hash: fetchurl {
    url = "https://repo1.maven.org/maven2/org/openjfx/javafx-${module}/${javafxVersion}/javafx-${module}-${javafxVersion}.jar";
    inherit hash;
  };

  javafxJars = {
    base = fetchJar "base" "sha256-rLqKDC2btfN0+avMf13wJTSVNkKEbgmfGkdlKXkzFqM=";
    graphics = fetchJar "graphics" "sha256-Em3a2XaQVhyEQAKf+FrDkRZc+9HKBkV+gRx8zOu2hoM=";
    # Для controls и fxml пока используем заглушку – после первой сборки Nix выдаст правильный хеш,
    # подставьте его сюда и пересоберите.
    controls = fetchJar "controls" "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
    fxml = fetchJar "fxml" "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
  };
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
