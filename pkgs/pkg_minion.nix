{ stdenv, fetchurl, openjdk21 }:

let
  # Берём openjdk21 с поддержкой JavaFX
  jdkWithFX = openjdk21.override { withJavaFX = true; };
in
stdenv.mkDerivation {
  pname = "minion";
  version = "3.0.12";

  src = fetchurl {
    url = "https://minion.gg/Minion-jfx.jar";
    hash = "sha256-rzVhoaLRAv6/xKxqEl+CTx9KfIL7ZR3rY8cAilNQjGg=";
  };

  dontUnpack = true;

  installPhase = ''
    mkdir -p $out/bin $out/share/minion
    cp $src $out/share/minion/Minion-jfx.jar

    cat > $out/bin/minion <<EOF
    #!${stdenv.shell}
    exec ${jdkWithFX}/bin/java \\
      --module-path ${jdkWithFX}/lib/javafx \\
      --add-modules javafx.base,javafx.controls,javafx.fxml,javafx.graphics \\
      -cp $out/share/minion/Minion-jfx.jar \\
      gg.minion.Minion "\$@"
    EOF
    chmod +x $out/bin/minion
  '';
}
