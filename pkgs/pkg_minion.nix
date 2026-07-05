{ stdenv, fetchzip, openjdk21, openjfx }:

stdenv.mkDerivation rec {
  pname = "minion";
  version = "3.0.12";

  src = fetchzip {
    url = "https://minion.gg/Minion-linux.zip";
    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # при первой сборке подставится правильный
    stripRoot = false;
  };

  installPhase = ''
    mkdir -p $out/bin $out/share/minion
    cp $src/Minion-jfx.jar $out/share/minion/

    # Находим путь к модулям JavaFX (автоматически)
    JAVAFX_MODULES=""
    for path in "${openjfx}/lib" "${openjfx}/share/java" $(find ${openjfx} -name "javafx.base.jar" -printf "%h" -quit 2>/dev/null); do
      if [ -d "$path" ] && [ -f "$path/javafx.base.jar" ]; then
        JAVAFX_MODULES="$path"
        break
      fi
    done
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
