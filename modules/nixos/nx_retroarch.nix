{ pkgs, ... }:

{
  programs.retroarch = {
    enable = true;
    cores = with pkgs.libretro; [
      mesen
      bsnes
      parallel-n64
      genesis-plus-gx
      beetle-saturn
      flycast
      ppsspp
      beetle-psx-hw
      pcsx2
    ];
  };
}
