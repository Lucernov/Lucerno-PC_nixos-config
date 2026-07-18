{ pkgs, pkgs-unstable, pkgs-minion }:

{
  minion = pkgs-minion.minion;
  qmmp = pkgs.callPackage ./pkg_qmmp.nix { };
  reaper = pkgs.callPackage ./pkg_reaper.nix { inherit (pkgs-unstable) reaper; };
  btop = pkgs.callPackage ./pkg_btop.nix { };
  kitty = pkgs.callPackage ./pkg_kitty.nix { };
}
