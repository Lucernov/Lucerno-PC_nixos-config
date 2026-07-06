{ pkgs, pkgs-unstable, pkgs-old }:
{
  minion = pkgs-old.minion;
  qmmp = pkgs.callPackage ./pkg_qmmp.nix { };
  reaper = pkgs.callPackage ./pkg_reaper.nix { inherit (pkgs-unstable) reaper; };
  btop = pkgs.callPackage ./pkg_btop.nix { };
}
