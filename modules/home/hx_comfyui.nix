{ pkgs, ... }:
{
  # Пользовательский systemd-сервис для запуска ComfyUI Сервис не запускается автоматически при входе в систему, а только по требованию или вручную systemctl --user start comfyui
  systemd.user.services.comfyui = {
    Unit.Description = "ComfyUI server (user)";                                                          # Описание сервиса (отображается в systemctl status)
      Service = {
        ExecStart = "${pkgs.comfy-ui-cuda}/bin/comfy-ui --listen 127.0.0.1 --port 8188 --normalvram";    # Команда запуска - только локальный доступ
        WorkingDirectory = "/mnt/ai/ComfyUI";                                                            # Рабочая директория (где лежат модели и workflows)
        Restart = "on-failure";                                                                          # Перезапускать сервис, если он упал с ошибкой
        RestartSec = 5;                                                                                  # Задержка перед перезапуском (5 секунд)
      };
    Install.WantedBy = [];                                                                               # Пустой список – сервис НЕ запускается автоматически при старте сессии
  };
}
