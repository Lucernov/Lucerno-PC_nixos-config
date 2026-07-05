{ symlinkJoin, makeWrapper, minion, fetchurl, stdenv, jre }:

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
  buildInputs = [ makeWrapper stdenv ];
  nativeBuildInputs = [ jre ]; # для доступа к java во время сборки
  postBuild = ''
    mkdir -p $out/share/minion/javafx
    cp ${javafxJars.base} $out/share/minion/javafx/javafx-base.jar
    cp ${javafxJars.controls} $out/share/minion/javafx/javafx-controls.jar
    cp ${javafxJars.fxml} $out/share/minion/javafx/javafx-fxml.jar
    cp ${javafxJars.graphics} $out/share/minion/javafx/javafx-graphics.jar

    rm -f $out/bin/minion

    cat > $out/bin/minion <<EOF
    #!${stdenv.shell}
    exec ${jre}/bin/java \\
      -Dprism.lcdtext=false -Dprism.text=t2k \\
      --module-path $out/share/minion/javafx \\
      --add-modules javafx.base,javafx.controls,javafx.fxml,javafx.graphics \\
      -jar $out/share/minion/Minion-jfx.jar "\$@"
    EOF
    chmod +x $out/bin/minion
  '';
}
