{ pkgs, myLib, ... }:

{
  systemd.services.comfyui = {
    description = "ComfyUI server (system)";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      User = myLib.userName;
      Group = myLib.userName;
      Type = "simple";
      WorkingDirectory = "/mnt/ai/ComfyUI";
      ExecStart = "${pkgs.comfy-ui-cuda}/bin/comfy-ui --listen 127.0.0.1 --port 8188";
      Restart = "on-failure";
      RestartSec = 5;
      Environment = [
        "CUDA_VISIBLE_DEVICES=0"
        "LD_LIBRARY_PATH=/run/opengl-driver/lib:/run/opengl-driver/lib64"
        "HOME=/home/lucerno"
      ];
      PrivateDevices = false;
      ProtectSystem = "off";
      ProtectHome = false;
      NoNewPrivileges = false;
      PrivateMounts = false;
      MountFlags = "shared";
      SupplementaryGroups = [ "fuse" "render" "video" "nvidia" ];
      DeviceAllow = [
        "/dev/fuse"
        "/dev/nvidia0"
        "/dev/nvidiactl"
        "/dev/nvidia-uvm"
        "/dev/nvidia-uvm-tools"
        "/dev/nvidia-modeset"
        "/dev/dri/*"
      ];
      DevicePolicy = "closed";
      AmbientCapabilities = [ "CAP_SYS_ADMIN" ];
    };
  };
}
