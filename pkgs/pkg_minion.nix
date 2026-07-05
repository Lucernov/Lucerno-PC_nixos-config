{ symlinkJoin, minion, openjdk21, openjfx, stdenv, findutils }:

symlinkJoin {
  name = "minion-wrapped";
  paths = [ minion ];
  buildInputs = [ stdenv findutils ];
  postBuild = ''
    # Находим основной jar-файл (не JavaFX)
    MAIN_JAR=$(find $out -name "*.jar" -type f ! -path "*/javafx/*" | head -n1)
    if [ -z "$MAIN_JAR" ]; then
      echo "No main jar found in $out" >&2
      exit 1
    fi
    echo "Main jar: $MAIN_JAR" >&2

    # Путь к модулям JavaFX из openjfx
    JAVAFX_MODULES=""
    for path in "${openjfx}/lib" "${openjfx}/share/java" $(find ${openjfx} -name "javafx.base.jar" -printf "%h" -quit 2>/dev/null); do
      if [ -d "$path" ] && [ -f "$path/javafx.base.jar" ]; then
        JAVAFX_MODULES="$path"
        break
      fi
    done
    if [ -z "$JAVAFX_MODULES" ]; then
      echo "JavaFX modules not found in ${openjfx}" >&2
      exit 1
    fi
    echo "JavaFX modules: $JAVAFX_MODULES" >&2

    # Удаляем старый скрипт (он не работает)
    rm -f $out/bin/minion

    # Создаём новый скрипт с правильными модулями
    cat > $out/bin/minion <<EOF
    #!${stdenv.shell}
    exec ${openjdk21}/bin/java \\
      --module-path "$JAVAFX_MODULES" \\
      --add-modules javafx.base,javafx.controls,javafx.fxml,javafx.graphics \\
      -cp "$MAIN_JAR" \\
      gg.minion.Minion "\$@"
    EOF
    chmod +x $out/bin/minion
  '';
}
