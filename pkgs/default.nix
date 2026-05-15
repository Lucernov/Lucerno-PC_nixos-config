{ pkgs, pkgs-unstable }:
{
  minion = pkgs.callPackage ./minion.nix { };
  qmmp = pkgs.callPackage ./qmmp.nix { };
  reaper = pkgs.callPackage ./reaper.nix { reaper = pkgs-unstable.reaper; };
  krita-ai = pkgs.callPackage ./krita-ai.nix { };
}
