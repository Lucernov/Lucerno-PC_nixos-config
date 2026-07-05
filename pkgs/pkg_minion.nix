{ stdenv, fetchurl, openjdk21, openjfx }:

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

    # Определяем путь к модулям JavaFX
    JAVAFX_MODULES=""
    if [ -d "${openjfx}/lib" ]; then
      JAVAFX_MODULES="${openjfx}/lib"
    elif [ -d "${openjfx}/share/java" ]; then
      JAVAFX_MODULES="${openjfx}/share/java"
    else
      # Ищем папку с javafx.base.jar
      JAVAFX_MODULES=$(find ${openjfx} -name "javafx.base.jar" -printf "%h" -quit 2>/dev/null)
    fi

    if [ -z "$JAVAFX_MODULES" ]; then
      echo "ERROR: JavaFX modules not found in ${openjfx}" >&2
      exit 1
    fi
    echo "JavaFX modules path: $JAVAFX_MODULES" >&2

    cat > $out/bin/minion <<EOF
    #!${stdenv.shell}
    exec ${openjdk21}/bin/java \\
      --module-path "$JAVAFX_MODULES" \\
      --add-modules javafx.base,javafx.controls,javafx.fxml,javafx.graphics \\
      -cp $out/share/minion/Minion-jfx.jar \\
      gg.minion.Minion "\$@"
    EOF
    chmod +x $out/bin/minion
  '';
}
