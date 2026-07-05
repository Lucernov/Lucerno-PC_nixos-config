{ symlinkJoin, minion, fetchurl, stdenv, jdk, unzip, findutils }:

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
  buildInputs = [ stdenv jdk unzip findutils ];
  postBuild = ''
    mkdir -p $out/share/minion/javafx
    cp ${javafxJars.base} $out/share/minion/javafx/javafx-base.jar
    cp ${javafxJars.controls} $out/share/minion/javafx/javafx-controls.jar
    cp ${javafxJars.fxml} $out/share/minion/javafx/javafx-fxml.jar
    cp ${javafxJars.graphics} $out/share/minion/javafx/javafx-graphics.jar

    rm -f $out/bin/minion

    # Находим все jar-файлы в пакете minion (везде)
    JARS=$(find $out -name "*.jar" -type f)
    echo "Found jars: $JARS" >&2

    # Пытаемся определить главный класс из любого jar с Main-Class
    MAIN_CLASS=""
    for jar in $JARS; do
      class=$(unzip -p "$jar" META-INF/MANIFEST.MF 2>/dev/null | grep -i 'Main-Class:' | sed 's/^[Mm]ain-[Cc]lass:[ ]*//' | tr -d '\r')
      if [ -n "$class" ]; then
        MAIN_CLASS="$class"
        break
      fi
    done
    [ -z "$MAIN_CLASS" ] && MAIN_CLASS="gg.minion.Minion"

    # Собираем classpath из всех jar-файлов + JavaFX
    CP=""
    for jar in $JARS; do
      CP="$CP:$jar"
    done
    for jar in $out/share/minion/javafx/*.jar; do
      CP="$CP:$jar"
    done
    CP="''${CP#:}"

    cat > $out/bin/minion <<EOF
    #!${stdenv.shell}
    exec ${jdk}/bin/java \\
      -Dprism.lcdtext=false -Dprism.text=t2k \\
      -cp "$CP" \\
      "$MAIN_CLASS" "\$@"
    EOF
    chmod +x $out/bin/minion
  '';
}
