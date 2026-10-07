# pkgs/pkg_noita-save-manager.nix
#
# Noita Save Manager — менеджер сохранений для игры Noita.
# Апстрим: https://github.com/mcgillij/noita_save_manager
#
# Особенности:
#   - Приложение на Python с GUI на PySimpleGUI (зависит также от psutil).
#   - PySimpleGUI удалён из nixpkgs, поэтому передаётся как локальный пакет
#     my-packages.pysimplegui (см. pkg_pysimplegui.nix).
#   - postInstall подменяет захардкоженный автором путь к сохранениям Noita
#     под Proton на корректный (~/.steam/steam/.../Nolla_Games_Noita).
#   - Обёртка запускает программу из ~/.local/share/noita_save_manager —
#     чтобы бэкапы сохранялись в предсказуемое место, а не в cwd.

{ lib
, python3
, fetchFromGitHub
, makeDesktopItem
, makeWrapper
, copyDesktopItems
, unstableGitUpdater
, pysimplegui
}:

python3.pkgs.buildPythonApplication rec {
  pname = "noita-save-manager";
  version = "0.1.4-unstable-2021-08-10";
  pyproject = true;

  pythonRelaxDeps = [ "pysimplegui" ];

  src = fetchFromGitHub {
    owner = "mcgillij";
    repo = "noita_save_manager";
    rev = "6f7f27bfd2b21fa0c7bf7b3eddc8e459106c946c";
    hash = "sha256-7PnumAL4tIDe6NaB0imepDmDXx8F3DXf8C7Xwvrlv84=";
  };

  desktopItem = makeDesktopItem {
    name = pname;
    exec = "noita_save_manager";
    comment = "Noita Savegame manager";
    desktopName = "Noita Save Manager";
    categories = [ "Game" "Utility" ];
  };

  nativeBuildInputs = [
    python3.pkgs.poetry-core
    makeWrapper
    copyDesktopItems
  ];

  propagatedBuildInputs = with python3.pkgs; [
    psutil
  ] ++ [
    pysimplegui
  ];

  desktopItems = [ desktopItem ];

  postInstall = ''
    SAVE_MANAGER="$(find "$out" -name save_manager.py)"
    substituteInPlace "$SAVE_MANAGER" \
      --replace '"/home/j/gits/save_noita"' \
                'os.path.expanduser("~") + "/.steam/steam/steamapps/compatdata/881100/pfx/drive_c/users/steamuser/AppData/LocalLow/Nolla_Games_Noita"'

    wrapProgram "$out/bin/noita_save_manager" \
      --run 'DIR="''${XDG_DATA_HOME:-$HOME/.local/share}"
             mkdir -p "$DIR/noita_save_manager"
             cd "$DIR/noita_save_manager"'
  '';

  pythonImportsCheck = [ "noita_save_manager" ];

  passthru.updateScript = unstableGitUpdater {
    branch = "master";
  };

  meta = with lib; {
    description = "Noita Savegame manager";
    homepage = "https://github.com/mcgillij/noita_save_manager";
    license = licenses.mit;
    mainProgram = "noita_save_manager";
    platforms = platforms.linux;
  };
}
