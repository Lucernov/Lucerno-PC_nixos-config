# modules/hx_comfyui.nix
# Пользовательский сервис ComfyUI, управляемый через systemd --user (без sudo)

{ pkgs, inputs, ... }:   # pkgs — стандартный набор пакетов Nixpkgs, inputs — все flake-входы

let
  # Берём готовую сборку ComfyUI с поддержкой CUDA (для видеокарты NVIDIA) из flake comfyui-nix (который добавлен в inputs в flake.nix)
  # ${pkgs.system} автоматически подставит текущую архитектуру (например, x86_64-linux)
  comfyui = inputs.comfyui-nix.packages.${pkgs.system}.comfy-ui-cuda;
in
{
  # Определяем пользовательский systemd-сервис (запускается от текущего пользователя, не от root)
  systemd.user.services.comfyui = {
    # Метаданные юнита
    Unit.Description = "ComfyUI server (user)";   # Описание сервиса (для systemctl status)

    # Параметры запуска сервиса
    Service = {
      # Команда запуска: путь к бинарнику ComfyUI + аргументы
      # --listen 127.0.0.1 — слушаем только локальный интерфейс (безопасно)
      # --port 8188 — порт, на котором будет доступен веб-интерфейс
      # --lowvram — экономит видеопамять на картах с 8 ГБ (RTX 3070)
      ExecStart = "${comfyui}/bin/comfy-ui --listen 127.0.0.1 --port 8188 --lowvram";

      # Рабочая директория — здесь лежат модели, custom_nodes, выходные изображения
      WorkingDirectory = "/mnt/ai/ComfyUI";

      # Перезапускать сервис, если процесс упал с ошибкой
      Restart = "on-failure";

      # Ждать 5 секунд перед перезапуском
      RestartSec = 5;
    };

    # Установка сервиса (в какие таргеты добавлять)
    # Пустой список WantedBy означает, что сервис НЕ БУДЕТ запускаться автоматически ни при загрузке системы, ни при старте пользовательской сессии.
    # Запуск только вручную: systemctl --user start comfyui
    Install.WantedBy = [];
  };
}
