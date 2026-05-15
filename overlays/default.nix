# overlays/default.nix
{ pkgs-unstable }:
final: prev: {
  my-packages = import ../pkgs { pkgs = final; pkgs-unstable = pkgs-unstable; };
}
