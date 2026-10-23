# pkgs/default.nix
{ pkgs-unstable }:

final: prev:
let
  versions = import ./versions.nix;
  pkgs = final;

  pysimplegui = pkgs.python3.pkgs.callPackage ./pkg_pysimplegui.nix { };                                                         # Убирает самосслку
  superfly = pkgs.callPackage ./pkg_SuperflyDSP.nix { inherit versions; };                                                       # SuperflyDSP: один .nix-файл возвращает ТРИ плагина (lostSamplers, lostTapes, lostVinyls)
in
{
  lucerno-packages = {
    # ====== Обёртки над пакетами nixpkgs ======
    btop = pkgs.callPackage ./wrap_btop.nix { };
    reaper = pkgs.callPackage ./wrap_reaper.nix {
      inherit (pkgs-unstable) reaper;
      cpupower = pkgs.linuxPackages_zen.cpupower;
    };
    teamspeak = pkgs.callPackage ./wrap_teamspeak.nix {
      teamspeak6-client = pkgs.teamspeak6-client;
      coreutils = pkgs.coreutils;
    };
    qmmp = pkgs.callPackage ./wrap_qmmp.nix { };

    # ====== ДЕРИВАЦИИ ======
    # Плагины для музыки
    air-g-plugins = pkgs.callPackage ./pkg_air-g-plugins.nix { inherit versions; };
    amp-locker = pkgs.callPackage ./pkg_Amp-Locker.nix { inherit versions; };
    drum-locker = pkgs.callPackage ./pkg_Drum-Locker.nix { inherit versions; };
    drumlabooh = pkgs.callPackage ./pkg_drumlabooh.nix { };                                                                       # Автообновление через nix-update
    drumlabooh-multi = pkgs.callPackage ./pkg_drumlabooh-multi.nix { };                                                           # Автообновление через nix-update
    je8086 = pkgs.callPackage ./pkg_JE8086.nix { };                                                                               # Автообновление через nix-update
    lostSamplers = superfly.lostSamplers;
    lostTapes    = superfly.lostTapes;
    lostVinyls   = superfly.lostVinyls;
    mtpdk = pkgs.callPackage ./pkg_MT-PowerDrumKit_2.nix { inherit versions; };
    mulhacen-clap = pkgs.callPackage ./pkg_Mulhacen.nix { };
    music-pattern-generator = pkgs.callPackage ./pkg_music-pattern-generator.nix { };                                             # Автообновление через nix-update
    numa-player = pkgs.callPackage ./pkg_numa-player.nix { inherit versions; };
    orchestools = pkgs.callPackage ./pkg_orchestools.nix { inherit versions; };
    ostirus = pkgs.callPackage ./pkg_OsTIrus.nix { };                                                                             # Автообновление через nix-update
    ot-piano-s = pkgs.callPackage ./pkg_ot-piano-s.nix { inherit versions; };
    pitchnet = pkgs.callPackage ./pkg_pitchnet.nix { };                                                                           # Автообновление через nix-update
    relic-clap = pkgs.callPackage ./pkg_Relic.nix { };
    satordist2 = pkgs.callPackage ./pkg_satordist2.nix { };
    sforzando = pkgs.callPackage ./pkg_sforzando.nix { inherit versions; };
    shortcircuit-xt = pkgs.callPackage ./pkg_shortcircuit-xt.nix { };                                                             # Автообновление через nix-update
    tal-vocoder-2 = pkgs.callPackage ./pkg_tal-vocoder-2.nix { inherit versions; };
    tape-echo-2 = pkgs.callPackage ./pkg_tape-echo-2.nix { };                                                                     # Автообновление через nix-update
    triplecheese = pkgs.callPackage ./pkg_Triple-Cheese.nix { };

    # ====== Шрифты ======
    apple-fonts-lite = pkgs.callPackage ./pkg_apple-fonts.nix { };

    # ====== Noita save manager ======
    # pysimplegui определён в let-блоке выше (общая зависимость).
    inherit pysimplegui;
    noita-save-manager = pkgs.callPackage ./pkg_noita-save-manager.nix {
      inherit pysimplegui;
    };

    # ====== Плагины для Krita ======
    krita-ai-diffusion = pkgs.callPackage ./pkg_krita-ai-diffusion.nix { };
    krita-vision-tools = pkgs.callPackage ./pkg_krita-vision-tools.nix { };

    # ====== Временный патч для Minion ======
    minion = pkgs.callPackage ./pkg_minion.nix { };
  };
}
