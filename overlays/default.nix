# overlays/default.nix
final: prev: {
  my-packages = import ../pkgs { pkgs = final; };
}
