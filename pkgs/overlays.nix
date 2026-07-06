# overlays.nix
{ pkgs-unstable, pkgs-old }:
final: prev: {
  my-packages = import ./default.nix {
    pkgs = final;
    pkgs-unstable = pkgs-unstable;
    pkgs-old = pkgs-old;
  };
}
