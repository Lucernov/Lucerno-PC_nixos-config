# overlays.nix
{ pkgs-unstable, pkgs-minion }:

final: prev: {
  my-packages = import ./default.nix {
    pkgs = final;
    pkgs-unstable = pkgs-unstable;
    pkgs-minion = pkgs-minion;
  };

    virtualbox = prev.virtualbox.overrideAttrs (old: {
    nativeBuildInputs = (old.nativeBuildInputs or []) ++ [ final.gcc ];
  });
}
