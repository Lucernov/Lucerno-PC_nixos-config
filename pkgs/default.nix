{ pkgs, pkgs-unstable, pkgs-minion }:

{
  minion = pkgs-minion.minion;
  qmmp = pkgs.callPackage ./pkg_qmmp.nix { };
  reaper = pkgs.callPackage ./pkg_reaper.nix { inherit (pkgs-unstable) reaper; };
  btop = pkgs.callPackage ./pkg_btop.nix { };
  teamspeak = pkgs.callPackage ./pkg_teamspeak.nix {
    teamspeak6-client = pkgs.teamspeak6-client;
    coreutils = pkgs.coreutils;
  };
  mtpdk = pkgs.callPackage ./pkg_MT-PowerDrumKit_2.nix { };
  drum-locker = pkgs.callPackage ./pkg_Drum-Locker.nix { };
  amp-locker = pkgs.callPackage ./pkg_Amp-Locker.nix { };
}
