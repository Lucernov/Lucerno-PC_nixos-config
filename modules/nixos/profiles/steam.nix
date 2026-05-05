{ pkgs-unstable, ... }:
{
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    extraCompatPackages = [ pkgs-unstable.proton-ge-bin ];
  };
  hardware.xone.enable = true;
  programs.gamemode = {
    enable = true;
    settings = {
      general = {
        desiredgov = "performance";
        reaper_freq = 5;
      };
    };
  };
}
