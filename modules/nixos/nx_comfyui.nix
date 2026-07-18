{ pkgs, myLib, ... }:

{
  systemd.services.comfyui = {
    description = "ComfyUI server (system)";
    after = [ "network.target" ];
    # Раскомментируйте следующую строку, если нужна автозагрузка при старте системы
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      User = myLib.userName;
      Group = myLib.userName;
      Type = "simple";
      WorkingDirectory = "/mnt/ai/ComfyUI";
      ExecStart = "${pkgs.comfy-ui-cuda}/bin/comfy-ui --listen 127.0.0.1 --port 8188";
      Restart = "on-failure";
      RestartSec = 5;
      # Разрешаем доступ к устройствам и снимаем ограничения
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
