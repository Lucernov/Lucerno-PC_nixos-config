# modules/hx_comfyui.nix
{ config, pkgs, ... }:
let
  comfyuiPython = "/mnt/ai/ComfyUI/.venv/bin/python";                                       # Путь к интерпретатору Python внутри виртуального окружения ComfyUI
  comfyuiMain = "/mnt/ai/ComfyUI/main.py";                                                  # Путь к главному скрипту ComfyUI (main.py)

  libraryPath = pkgs.lib.makeLibraryPath [                                                  # Формируем список путей к библиотекам, необходимым для работы ComfyUI
    pkgs.stdenv.cc.cc.lib                                                                   # libstdc++ (стандартная библиотека C++)
    pkgs.libxcb                                                                             # X C Binding (низкоуровневая X11)
    pkgs.libx11                                                                             # Основная библиотека X11
    pkgs.libxext                                                                            # Расширения X11
    pkgs.libxrender                                                                         # Рендеринг X11
    pkgs.glib                                                                               # GLib (основные структуры данных)
    pkgs.gtk3                                                                               # GTK+ 3 (некоторые плагины могут требовать)
    pkgs.opencv                                                                             # OpenCV (компьютерное зрение, используется в некоторых узлах)
    pkgs.libGL                                                                              # OpenGL (ускорение графики)
  ];
in
{

  systemd.user.services.comfyui = {                                                         # Определение systemd-сервиса для пользователя
    Unit = {
      Description = "ComfyUI Server";                                                       # Описание сервиса
      After = [ "network.target" ];                                                         # Запускать после того, как сеть уже поднята
    };
    Service = {
      Type = "simple";                                                                      # Обычный процесс (не разветвляется)
      ExecStart = "${comfyuiPython} ${comfyuiMain} --listen 127.0.0.1 --port 8188";         # Команда запуска: python main.py с прослушиванием локального порта 8188
      WorkingDirectory = "/mnt/ai/ComfyUI";                                                 # Рабочая директория сервера
      Restart = "on-failure";                                                               # Перезапускать при сбое
      RestartSec = 5;                                                                       # Ждать 5 секунд перед перезапуском
      Environment = [                                                                       # Переменные окружения для процесса
        "PATH=/run/current-system/sw/bin:/usr/bin"                                          # Пути поиска исполняемых файлов
        "LD_LIBRARY_PATH=${libraryPath}:/run/current-system/sw/lib:/run/opengl-driver/lib"  # Пути поиска библиотек
      ];
    };
#    Install = {
#      WantedBy = [ "default.target" ];                                                     # Автозапуск сервиса при старте пользовательской сессии
#    };
  };
}
