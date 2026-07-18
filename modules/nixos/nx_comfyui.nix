{ pkgs, myLib, ... }:

{
  # Пользовательский systemd-сервис для запуска ComfyUI Сервис не запускается автоматически при входе в систему, а только по требованию или вручную systemctl --user start comfyui
  systemd.services.comfyui = {
    description = "ComfyUI server (system)";                                                          # Описание сервиса (отображается в systemctl status)
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      User = myLib.userName;
      Group = myLib.userName;
      WorkingDirectory = "/mnt/ai/ComfyUI";                                                            # Рабочая директория (где лежат модели и workflows)
      ExecStart = "${pkgs.comfy-ui-cuda}/bin/comfy-ui --listen 127.0.0.1 --port 8188 --normalvram";    # Команда запуска - только локальный доступ
      Restart = "on-failure";                                                                          # Перезапускать сервис, если он упал с ошибкой
      RestartSec = 5;                                                                                  # Задержка перед перезапуском (5 секунд)
    };
  };
}
