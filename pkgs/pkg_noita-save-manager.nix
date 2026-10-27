# pkgs/pkg_noita-save-manager.nix
#
# Noita Save Manager — менеджер сохранений для игры Noita.
# Апстрим: https://github.com/mcgillij/noita_save_manager
#
# Особенности:
#   - Приложение на Python с GUI на PySimpleGUI (зависит также от psutil).
#   - PySimpleGUI удалён из nixpkgs, поэтому объявлен локально в let-блоке.
#   - postInstall подменяет захардкоженный автором путь к сохранениям Noita
#     под Proton на корректный (~/.steam/steam/.../Nolla_Games_Noita).
#   - Обёртка запускает программу из ~/.local/share/noita_save_manager —
#     чтобы бэкапы сохранялись в предсказуемое место, а не в cwd.
#   - АВТООБНОВЛЕНИЕ НЕ ПОДКЛЮЧЕНО сознательно:
#       • апстрим не менялся с 2021 года (последний коммит 6f7f27b);
#       • unstableGitUpdater не работает в flake-контексте.
#     Если апстрим оживёт — обновлять вручную:
#       nix-prefetch-github mcgillij noita_save_manager --rev <новый-коммит>
#     и править rev/hash/version в этом файле.

{ lib
, python3
, fetchFromGitHub
, fetchurl
, makeDesktopItem
, makeWrapper
, copyDesktopItems
}:

let
  # Иконка теперь берется удаленно из LFS
  icon = fetchurl {
    url = "https://media.githubusercontent.com/media/Lucernov/Lucerno-PC_nixos-config/main/dotfiles/sys-icons/icon-noita-save-manager.png";
    hash = "sha256-jqpNQ0oeBKZmaJXukmfQJKZXR1V5NqiwmWSZcM7qMcQ=";
  };

  # Встроенный PySimpleGUI (используется только здесь)
  pysimplegui = python3.pkgs.buildPythonPackage {
    pname = "pysimplegui";
    version = "6.3";
    pyproject = true;

    src = fetchFromGitHub {
      owner = "PySimpleGUI";
      repo = "PySimpleGUI";
      rev = "8d00420665f265836205b9e7dd71bff2621d399a";
      hash = "sha256-79/pSgBqD4Nlmhm3l1cXyV40ve4CZAFjZJ9XjPecp7A=";
    };

    build-system = [ python3.pkgs.setuptools ];
    propagatedBuildInputs = [ python3.pkgs.tkinter ];
    pythonImportsCheck = [ "PySimpleGUI" ];

    meta = with lib; {
      description = "Python GUIs for Humans (LGPL3 community version)";
      homepage = "https://github.com/PySimpleGUI/PySimpleGUI";
      license = licenses.lgpl3Plus;
      platforms = platforms.linux;
    };
  };
in
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
    categories = [ "Game" ];
    icon = "icon-noita-save-manager";
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
      --replace-fail '"/home/j/gits/save_noita"' \
                'os.path.expanduser("~") + "/.steam/steam/steamapps/compatdata/881100/pfx/drive_c/users/steamuser/AppData/LocalLow/Nolla_Games_Noita"'

    wrapProgram "$out/bin/noita_save_manager" \
      --run 'DIR="''${XDG_DATA_HOME:-$HOME/.local/share}"
             mkdir -p "$DIR/noita_save_manager"
             cd "$DIR/noita_save_manager"'

    install -Dm644 ${icon} \
      $out/share/icons/hicolor/256x256/apps/icon-noita-save-manager.png
  '';

  pythonImportsCheck = [ "noita_save_manager" ];

  meta = with lib; {
    description = "Noita Savegame manager";
    homepage = "https://github.com/mcgillij/noita_save_manager";
    license = licenses.mit;
    mainProgram = "noita_save_manager";
    platforms = platforms.linux;
  };
}
