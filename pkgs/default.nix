{ pkgs }:
{
  minion = pkgs.callPackage ./minion.nix { };
  # при необходимости добавьте другие пакеты:
  # another-pkg = pkgs.callPackage ./another-pkg.nix { };
}
