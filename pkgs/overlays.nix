# overlays.nix
{ pkgs-unstable }:
final: prev: {
  my-packages = import ./default.nix { pkgs = final; pkgs-unstable = pkgs-unstable; };
}
