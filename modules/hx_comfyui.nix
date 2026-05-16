# modules/hx_comfyui.nix
{ config, pkgs, ... }:
let
  comfyuiPython = "/mnt/ai/ComfyUI/.venv/bin/python";
  comfyuiMain = "/mnt/ai/ComfyUI/main.py";
  libraryPath = pkgs.lib.makeLibraryPath [
    pkgs.stdenv.cc.cc.lib
    pkgs.libxcb
    pkgs.libx11
    pkgs.libxext
    pkgs.libxrender
    pkgs.glib
    pkgs.gtk3
    pkgs.opencv
    pkgs.libGL
  ];
in
{
  systemd.user.services.comfyui = {
    Unit = {
      Description = "ComfyUI Server";
      After = [ "network.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = "${comfyuiPython} ${comfyuiMain} --listen 127.0.0.1 --port 8188";
      WorkingDirectory = "/mnt/ai/ComfyUI";
      Restart = "on-failure";
      RestartSec = 5;
      Environment = [
        "PATH=/run/current-system/sw/bin:/usr/bin"
        "LD_LIBRARY_PATH=${libraryPath}:/run/current-system/sw/lib:/run/opengl-driver/lib"
      ];
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };
}
