{ pkgs, pkgs-unstable }:
{
  minion = pkgs.callPackage ./pkg_minion.nix { };
  qmmp = pkgs.callPackage ./pkg_qmmp.nix { };
  reaper = pkgs.callPackage ./pkg_reaper.nix { reaper = pkgs-unstable.reaper; };
  btop = pkgs.callPackage ./pkg_btop.nix { };
  proton-authenticator = pkgs.callPackage ./pkg_proton-authenticator.nix { };
}
