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
    reaper = pkgs.callPackage ./pkg_reaper.nix { inherit (pkgs-unstable) reaper; cpupower = pkgs.linuxPackages_zen.cpupower; };
    teamspeak = pkgs.callPackage ./pkg_teamspeak.nix {
      teamspeak6-client = pkgs.teamspeak6-client;
      coreutils = pkgs.coreutils;
    };
    qmmp = pkgs.callPackage ./pkg_qmmp.nix { };

    # ====== ДЕРИВАЦИИ ======
    air-g-plugins = pkgs.callPackage ./pkg_air-g-plugins.nix { inherit versions; };
    amp-locker = pkgs.callPackage ./pkg_Amp-Locker.nix { inherit versions; };
    drum-locker = pkgs.callPackage ./pkg_Drum-Locker.nix { inherit versions; };
    drumlabooh = pkgs.callPackage ./pkg_drumlabooh.nix { inherit versions; };
    je8086 = pkgs.callPackage ./pkg_JE8086.nix { inherit versions; };
    lostSamplers = (pkgs.callPackage ./pkg_SuperflyDSP.nix { inherit versions; }).lostSamplers;
    lostTapes    = (pkgs.callPackage ./pkg_SuperflyDSP.nix { inherit versions; }).lostTapes;
    lostVinyls   = (pkgs.callPackage ./pkg_SuperflyDSP.nix { inherit versions; }).lostVinyls;
    mtpdk = pkgs.callPackage ./pkg_MT-PowerDrumKit_2.nix { inherit versions; };
    music-pattern-generator = pkgs.callPackage ./pkg_music-pattern-generator.nix { inherit versions; };
    orchestools = pkgs.callPackage ./pkg_orchestools.nix { inherit versions; };
    ostirus = pkgs.callPackage ./pkg_OsTIrus.nix { inherit versions; };
    ot-piano-s = pkgs.callPackage ./pkg_ot-piano-s.nix { inherit versions; };
    pitchnet = pkgs.callPackage ./pkg_pitchnet.nix { inherit versions; };
    sforzando = pkgs.callPackage ./pkg_sforzando.nix { inherit versions; };
    shortcircuit-xt = pkgs.callPackage ./pkg_shortcircuit-xt.nix { inherit versions; };
    tal-vocoder-2 = pkgs.callPackage ./pkg_tal-vocoder-2.nix { inherit versions; };
    tape-echo-2 = pkgs.callPackage ./pkg_tape-echo-2.nix { inherit versions; };
  };
}
