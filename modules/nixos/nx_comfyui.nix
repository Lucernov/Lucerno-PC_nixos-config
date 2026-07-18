{ pkgs, myLib, ... }:

{
  systemd.services.comfyui = {
    description = "ComfyUI server (system)";
    after = [ "network.target" ];
    # раскомментируйте для автозагрузки
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      User = myLib.userName;
      Group = myLib.userName;
      Type = "simple";
      WorkingDirectory = "/mnt/ai/ComfyUI";
      ExecStart = "${pkgs.comfy-ui-cuda}/bin/comfy-ui --listen 127.0.0.1 --port 8188";
      Restart = "on-failure";
      RestartSec = 5;
      # Переменные окружения для CUDA
      Environment = [
        "CUDA_VISIBLE_DEVICES=0"
        "LD_LIBRARY_PATH=/run/opengl-driver/lib"
      ];
      # Остальные опции для доступа к устройствам
      PrivateDevices = false;
      ProtectSystem = "off";
      ProtectHome = false;
      NoNewPrivileges = false;
      PrivateMounts = false;
      MountFlags = "shared";
      SupplementaryGroups = [ "fuse" "render" "video" ];
      DeviceAllow = [ "/dev/fuse" "/dev/nvidia*" "/dev/dri/*" ];
      DevicePolicy = "auto";
      AmbientCapabilities = [ "CAP_SYS_ADMIN" ];
    };
  };
}
