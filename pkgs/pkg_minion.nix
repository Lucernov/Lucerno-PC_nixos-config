{ symlinkJoin, minion, fetchurl, stdenv, jdk }:

let
  javafxVersion = "21.0.3";
  jars = [
    { name = "base";     hash = "sha256-rLqKDC2btfN0+avMf13wJTSVNkKEbgmfGkdlKXkzFqM="; }
    { name = "controls"; hash = "sha256-jJoO2l64CuIT8sqtkbHGazT4WYSykLXUrbxMgQCGrLc="; }
    { name = "fxml";     hash = "sha256-bhtaPEKtEjYzOo2TPWxIzmOugtiindNQDghqvgvX/0k="; }
    { name = "graphics"; hash = "sha256-Em3a2XaQVhyEQAKf+FrDkRZc+9HKBkV+gRx8zOu2hoM="; }
  ];
  javafxJars = builtins.listToAttrs (map (j: {
    name = j.name;
    value = fetchurl {
      url = "https://repo1.maven.org/maven2/org/openjfx/javafx-${j.name}/${javafxVersion}/javafx-${j.name}-${javafxVersion}.jar";
      hash = j.hash;
    };
  }) jars);
in symlinkJoin {
  name = "minion-wrapped";
  paths = [ minion ];
  buildInputs = [ stdenv jdk ];
  postBuild = ''
    mkdir -p $out/share/minion/javafx
    cp ${javafxJars.base} $out/share/minion/javafx/javafx-base.jar
    cp ${javafxJars.controls} $out/share/minion/javafx/javafx-controls.jar
    cp ${javafxJars.fxml} $out/share/minion/javafx/javafx-fxml.jar
    cp ${javafxJars.graphics} $out/share/minion/javafx/javafx-graphics.jar

    # Отладка – выводим содержимое папок в лог сборки
    echo "=== Contents of $out/share/minion ===" >&2
    ls -la $out/share/minion/ >&2 || true
    echo "=== Contents of javafx dir ===" >&2
    ls -la $out/share/minion/javafx/ >&2 || true

    # Удаляем оригинальный скрипт
    rm -f $out/bin/minion

    # Формируем classpath вручную
    CP="$out/share/minion/javafx/javafx-base.jar:$out/share/minion/javafx/javafx-controls.jar:$out/share/minion/javafx/javafx-fxml.jar:$out/share/minion/javafx/javafx-graphics.jar:$out/share/minion/Minion-jfx.jar"

    cat > $out/bin/minion <<EOF
    #!${stdenv.shell}
    exec ${jdk}/bin/java \\
      -Dprism.lcdtext=false -Dprism.text=t2k \\
      -cp "$CP" \\
      gg.minion.Minion "\$@"
    EOF
    chmod +x $out/bin/minion
  '';
}
