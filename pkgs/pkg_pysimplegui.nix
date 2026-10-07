# pkgs/pkg_pysimplegui.nix
#
# PySimpleGUI — GUI-фреймворк для Python.
#
# Особенности:
#   - Пакет УДАЛЁН из nixpkgs: сначала из-за смены лицензии на проприетарную
#     в версии 5.x, затем из-за закрытия проекта в 2025 году.
#   - С версии 6.x проект возрождён сообществом на GitHub под LGPL3.
#   - Использует классический setup.py (не pyproject.toml), поэтому
#     собирается стандартным setuptools. Никакого format = "other" не нужно.
#   - tkinter — единственная зависимость.
#   - Используется в noita-save-manager (см. pkg_noita-save-manager.nix).
#
# Обновление версии:
#   1. Посмотреть последний тег:  https://github.com/PySimpleGUI/PySimpleGUI/releases
#   2. Получить хэш:               nix-prefetch-github PySimpleGUI PySimpleGUI --rev <тег>
#   3. Обновить version и hash ниже.

{ lib
, buildPythonPackage
, fetchFromGitHub
, setuptools
, tkinter
}:

buildPythonPackage {
  pname = "pysimplegui";
  version = "6.3";
  format = "setuptools";

  src = fetchFromGitHub {
    owner = "PySimpleGUI";
    repo = "PySimpleGUI";
    rev = "8d00420665f265836205b9e7dd71bff2621d399a";
    hash = "sha256-79/pSgBqD4Nlmhm3l1cXyV40ve4CZAFjZJ9XjPecp7A=";
  };

  build-system = [ setuptools ];

  propagatedBuildInputs = [ tkinter ];

  # pythonImportsCheck может упасть, если импорт тянет X11-дисплей.
  # Пока оставляем, но если сборка упадёт — просто уберём эту строку.
  pythonImportsCheck = [ "PySimpleGUI" ];

  meta = with lib; {
    description = "Python GUIs for Humans (LGPL3 community version)";
    homepage = "https://github.com/PySimpleGUI/PySimpleGUI";
    license = licenses.lgpl3Plus;
    platforms = platforms.linux;
  };
}
