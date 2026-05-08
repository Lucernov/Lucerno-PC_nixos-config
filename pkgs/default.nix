{ pkgs }:
{
  minion = pkgs.callPackage ./minion.nix { };
  parabolic = pkgs.callPackage ./parabolic.nix { };
}
