# pkgs/pkg_minion.nix
#
# Minion — менеджер аддонов для ESO/WoW (MMOUI).
#
# ЭТО ЛОКАЛЬНАЯ КОПИЯ с применённым PR #539572:
#   https://github.com/NixOS/nixpkgs/pull/539572
# Когда PR смержат в nixpkgs — этот файл можно удалить и вернуться
# к minion из основного канала.
#
# ВАЖНО про имя файла:
#   pkg_minion.nix (с подчёркиванием) — чтобы не пересекаться с
#   nixpkgs-конвенцией именования (by-name lowercase через дефис).
#
# ВАЖНО про патч JavaFX (PR #539572):
#   Minion падает с "JavaFX runtime components are missing", когда main-класс
#   напрямую наследует Application. Решение — класс-обёртка Launcher,
#   который вызывает gg.minion.Minion.main(). JavaFX тогда стартует
#   корректно, потому что main не в классе-наследнике Application.
#
# ВАЖНО про makeWrapper в preFixup:
#   GLib-GIO-ERROR "No GSettings schemas are installed" возникает, если
#   makeWrapper вызывается до того, как gappsWrapperArgs заполнен хуком
#   wrapGAppsHook3. preFixup — единственный момент, когда gappsWrapperArgs
#   уже готов, но окружение ещё не закрыто. См.:
#   https://ryantm.github.io/nixpkgs/languages-frameworks/gnome/
#
# ВАЖНО про makeWrapper vs makeBinaryWrapper:
#   makeBinaryWrapper не поддерживает --add-flags (issue #172320).
#   wrapGAppsHook3 — это результат wrapGAppsNoGuiHook.override { isGraphical = true; },
#   и у него нет аргумента makeBinaryWrapper. Переопределяем
#   wrapGAppsNoGuiHook, который принимает makeWrapper через callPackage.
#
# ВАЖНО про JFX_MODULES / JFX_NATIVE:
#   openjfx21 с withWebKit=true предоставляет модули по отдельным путям
#   (modules/ и modules_libs/). Их нужно передавать и в javac (для компиляции
#   Launcher.java), и в java (для запуска), и в -Djava.library.path (для
#   нативных .so JavaFX).

{ stdenvNoCC
, lib
, fetchzip
, openjfx21
, openjdk21
, makeDesktopItem
, copyDesktopItems
, wrapGAppsNoGuiHook
, makeWrapper
}:

let
  # openjfx с WebKit — нужен для встроенного браузера в Minion.
  openjfx_jdk = openjfx21.override { withWebKit = true; };

  # openjdk с включённым JavaFX — иначе java не увидит модули openjfx.
  openjdk = openjdk21.override {
    enableJavaFX = true;
    inherit openjfx_jdk;
  };

  # Переопределяем wrapGAppsNoGuiHook, чтобы он использовал скриптовый
  # makeWrapper вместо makeBinaryWrapper. Это необходимо для работы
  # --add-flags (см. issue #172320).
  wrapGAppsHook = wrapGAppsNoGuiHook.override {
    makeWrapper = makeWrapper;
    isGraphical = true;
  };

  # Wrapper-класс для обхода "JavaFX runtime components are missing".
  # JavaFX требует, чтобы main-класс не наследовал Application напрямую.
  # https://www.reddit.com/r/JavaFX/comments/k7aa9q/
  launcherSrc = builtins.toFile "Launcher.java" ''
    public class Launcher {
        public static void main(String[] args) {
            gg.minion.Minion.main(args);
        }
    }
  '';
in
stdenvNoCC.mkDerivation rec {
  pname = "minion";
  version = "3.0.12";

  src = fetchzip {
    url = "https://cdn.mmoui.com/minion/v3/Minion${version}-java.zip";
    hash = "sha256-KjSj3TBMY3y5kgIywtIDeil0L17dau/Rb2HuXAulSO8=";
    stripRoot = false;
  };

  nativeBuildInputs = [
    makeWrapper
    copyDesktopItems
    wrapGAppsHook
  ];

  # Сами вызываем makeWrapper в preFixup с gappsWrapperArgs — хук не нужен.
  dontWrapGApps = true;

  # Компилируем Launcher.java и кладём .class рядом с jar.
  buildPhase = ''
    runHook preBuild

    cp ${launcherSrc} Launcher.java

    JFX_MODULES="${openjfx_jdk}/modules/javafx.base:${openjfx_jdk}/modules/javafx.controls:${openjfx_jdk}/modules/javafx.graphics:${openjfx_jdk}/modules/javafx.fxml:${openjfx_jdk}/modules/javafx.web:${openjfx_jdk}/modules/javafx.media:${openjfx_jdk}/modules/javafx.swing"

    ${openjdk}/bin/javac -cp "Minion-jfx.jar:lib/*:$JFX_MODULES" Launcher.java -d .

    runHook postBuild
  '';

  # Раскладываем бинарные артефакты в $out/share/minion.
  installPhase = ''
    runHook preInstall

    mkdir -p "$out/share/minion"

    install -D Launcher.class "$out/share/minion/Launcher.class"
    install -D Minion-jfx.jar "$out/share/minion/Minion-jfx.jar"
    cp -r ./lib "$out/share/minion/"

    runHook postInstall
  '';

  # makeWrapper живёт в preFixup, потому что gappsWrapperArgs заполняется
  # только к этому моменту. JFX_NATIVE нужен, чтобы JavaFX нашёл нативные .so.
  preFixup = ''
    JFX_MODULES="${openjfx_jdk}/modules/javafx.base:${openjfx_jdk}/modules/javafx.controls:${openjfx_jdk}/modules/javafx.graphics:${openjfx_jdk}/modules/javafx.fxml:${openjfx_jdk}/modules/javafx.web:${openjfx_jdk}/modules/javafx.media:${openjfx_jdk}/modules/javafx.swing"
    JFX_NATIVE="${openjfx_jdk}/modules_libs/javafx.graphics:${openjfx_jdk}/modules_libs/javafx.web:${openjfx_jdk}/modules_libs/javafx.media"

    makeWrapper ${lib.getExe openjdk} $out/bin/minion \
      "''${gappsWrapperArgs[@]}" \
      --add-flags "-Djava.library.path=$JFX_NATIVE" \
      --add-flags "-cp $out/share/minion:$out/share/minion/Minion-jfx.jar:$out/share/minion/lib/*:$JFX_MODULES" \
      --add-flags "--add-opens=java.base/java.lang=ALL-UNNAMED" \
      --add-flags "--add-exports=javafx.graphics/com.sun.javafx.css=ALL-UNNAMED" \
      --add-flags "--add-exports=javafx.graphics/javafx.scene.image=ALL-UNNAMED" \
      --add-flags "--add-opens=javafx.graphics/javafx.scene.image=ALL-UNNAMED" \
      --add-flags "Launcher"
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "minion";
      exec = "minion";
      comment = "MMO Addon manager for Elder Scrolls Online and World of Warcraft";
      desktopName = "Minion";
      categories = [ "Game" ];
    })
  ];

  meta = {
    description = "Addon manager for World of Warcraft and The Elder Scrolls Online";
    homepage = "https://minion.mmoui.com/";
    license = lib.licenses.unfree;
    platforms = lib.platforms.linux;
    mainProgram = "minion";
    maintainers = with lib.maintainers; [ patrickdag ];
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
  };
}
