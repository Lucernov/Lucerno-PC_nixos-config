{ pkgs, ... }:
{
  systemd.user.services.comfyui = {
    Unit.Description = "ComfyUI server (user)";
      Service = {
        ExecStart = "${pkgs.comfy-ui-cuda}/bin/comfy-ui --listen 127.0.0.1 --port 8188 --lowvram";
        WorkingDirectory = "/mnt/ai/ComfyUI";
        Restart = "on-failure";
        RestartSec = 5;
      };
    Install.WantedBy = [];
  };
}
