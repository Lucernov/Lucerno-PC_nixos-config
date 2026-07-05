{ symlinkJoin, minion, fetchurl, stdenv, jdk, unzip }:

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
  buildInputs = [ stdenv jdk unzip ];
  postBuild = ''
    mkdir -p $out/share/minion/javafx
    cp ${javafxJars.base} $out/share/minion/javafx/javafx-base.jar
    cp ${javafxJars.controls} $out/share/minion/javafx/javafx-controls.jar
    cp ${javafxJars.fxml} $out/share/minion/javafx/javafx-fxml.jar
    cp ${javafxJars.graphics} $out/share/minion/javafx/javafx-graphics.jar

    rm -f $out/bin/minion

    # Находим основной jar-файл (первый попавшийся в share/minion)
    MAIN_JAR="$(find $out/share/minion -maxdepth 1 -name "*.jar" -type f | head -n 1)"
    if [ -z "$MAIN_JAR" ]; then
      echo "No jar found in $out/share/minion" >&2
      exit 1
    fi

    # Пытаемся извлечь Main-Class из MANIFEST.MF
    MAIN_CLASS="$(unzip -p "$MAIN_JAR" META-INF/MANIFEST.MF | grep -i 'Main-Class:' | sed 's/^[Mm]ain-[Cc]lass:[ ]*//' | tr -d '\r' || true)"
    if [ -z "$MAIN_CLASS" ]; then
      MAIN_CLASS="gg.minion.Minion"  # fallback
    fi

    # Собираем classpath: основной jar + все javafx
    CP="$MAIN_JAR"
    for jar in $out/share/minion/javafx/*.jar; do
      CP="$CP:$jar"
    done

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
