# pkgs/default.nix
{ pkgs-unstable }:

let
  versions = import ./versions.nix;
in

final: prev: {
  my-packages = let
    pkgs = final;
  in {
    btop = pkgs.callPackage ./pkg_btop.nix { };
    reaper = pkgs.callPackage ./pkg_reaper.nix { inherit (pkgs-unstable) reaper; };
    teamspeak = pkgs.callPackage ./pkg_teamspeak.nix {
      teamspeak6-client = pkgs.teamspeak6-client;
      coreutils = pkgs.coreutils;
    };
    qmmp = pkgs.callPackage ./pkg_qmmp.nix { };

    # ====== ДЕРИВАЦИИ ======
    amp-locker = pkgs.callPackage ./pkg_Amp-Locker.nix { inherit versions; };
    drum-locker = pkgs.callPackage ./pkg_Drum-Locker.nix { inherit versions; };
    drumlabooh = pkgs.callPackage ./pkg_drumlabooh.nix { inherit versions; };
    mtpdk = pkgs.callPackage ./pkg_MT-PowerDrumKit_2.nix { inherit versions; };
    orchestools = pkgs.callPackage ./pkg_orchestools.nix { inherit versions; };
    ostirus = pkgs.callPackage ./pkg_OsTIrus.nix { inherit versions; };
    ot-piano-s = pkgs.callPackage ./pkg_ot-piano-s.nix { inherit versions; };
    shortcircuit-xt = pkgs.callPackage ./pkg_shortcircuit-xt.nix { inherit versions; };
  };
}
