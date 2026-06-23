{ config, pkgs, ... }:
{
  home.file.".config/katerc" = {
    text = ''
      [General]
      Font=JetBrains Mono,13,-1,5,50,0,0,0,0,0
    '';
    force = true;
  };
}
