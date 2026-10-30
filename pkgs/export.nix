# pkgs/export.nix
{ pkgs }:
{
  # Обновляемые через nix-update
  drumlabooh = pkgs.lucerno-packages.drumlabooh;
  drumlabooh-multi = pkgs.lucerno-packages.drumlabooh-multi;
  je8086 = pkgs.lucerno-packages.je8086;
  music-pattern-generator = pkgs.lucerno-packages.music-pattern-generator;
  ostirus = pkgs.lucerno-packages.ostirus;
  pitchnet = pkgs.lucerno-packages.pitchnet;
  satordist2 = pkgs.lucerno-packages.satordist2;
  shortcircuit-xt = pkgs.lucerno-packages.shortcircuit-xt;
  tape-echo-2 = pkgs.lucerno-packages.tape-echo-2;

  # Пакеты с ассетами в GitHub Releases
  air-g-plugins = pkgs.lucerno-packages.air-g-plugins;
  orchestools = pkgs.lucerno-packages.orchestools;
  ot-piano-s = pkgs.lucerno-packages.ot-piano-s;
  relic-clap = pkgs.lucerno-packages.relic-clap;

  # Самодостаточные пакеты (ручное обновление)
  amp-locker = pkgs.lucerno-packages.amp-locker;
  drum-locker = pkgs.lucerno-packages.drum-locker;
  mtpdk = pkgs.lucerno-packages.mtpdk;
  lostSamplers = pkgs.lucerno-packages.lostSamplers;
  lostTapes = pkgs.lucerno-packages.lostTapes;
  lostVinyls = pkgs.lucerno-packages.lostVinyls;
  sforzando = pkgs.lucerno-packages.sforzando;
  numa-player = pkgs.lucerno-packages.numa-player;
  tal-vocoder-2 = pkgs.lucerno-packages.tal-vocoder-2;
  tdr-nova = pkgs.lucerno-packages.tdr-nova;
}
