{ config, pkgs, ... }:
let
  myMinion = pkgs.callPackage ./pkgs/pkg_minion.nix { };
in {
  environment.systemPackages = [ myMinion ];
}
