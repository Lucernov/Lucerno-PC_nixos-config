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
      ExecStart = "${pkgs.comfy-ui-cuda}/bin/comfy-ui --listen 127.0.0.1 --port 8188 --normalvram";
      Restart = "on-failure";
      RestartSec = 5;
      # Опции для доступа к устройствам и привилегиям (аналогично rclone)
      PrivateDevices = false;
      ProtectSystem = "off";
      ProtectHome = false;
      NoNewPrivileges = false;
      PrivateMounts = false;
      MountFlags = "shared";
      SupplementaryGroups = [ "fuse" "render" "video" ]; # для доступа к GPU и FUSE
      DeviceAllow = [ "/dev/fuse" "/dev/nvidia*" "/dev/dri/*" ];
      DevicePolicy = "auto";
      AmbientCapabilities = [ "CAP_SYS_ADMIN" ];
    };
  };
}
