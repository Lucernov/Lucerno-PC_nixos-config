# modules/nx_ollama.nix
#
# Управление сервером Ollama (локальная LLM) через systemd user-сервис.
# Модели хранятся на внешнем диске: /mnt/ai/Ollama/models
# (симлинк ~/.ollama -> /mnt/ai/Ollama настраивается в modules/hi_links.nix)
#
# Сервис запускается от имени пользователя, поэтому sudo не требуется.
# Управление: systemctl --user start/stop/status ollama

{ pkgs, myLib, ... }:

let
  inherit (myLib) home;

  # ---------- Скрипты управления ----------
  startScript = pkgs.writeShellScript "start-ollama" ''
    systemctl --user start ollama
  '';

  stopScript = pkgs.writeShellScript "stop-ollama" ''
    systemctl --user stop ollama
  '';

  restartScript = pkgs.writeShellScript "restart-ollama" ''
    systemctl --user restart ollama
  '';

  statusScript = pkgs.writeShellScript "status-ollama" ''
    kitty --title "Ollama Status" bash -c "systemctl --user status ollama; echo 'Press any key to close...'; read -n 1"
  '';

  # ---------- .desktop файлы ----------
  startDesktop = pkgs.writeTextFile {
    name = "ollama-start.desktop";
    destination = "/share/applications/ollama-start.desktop";
    text = ''
      [Desktop Entry]
      Version=1.0
      Type=Application
      Name=Start Ollama
      Comment=Start Ollama server
      Exec=${startScript}
      Icon=applications-development
      Categories=Development;
      Terminal=false
      StartupNotify=false
    '';
  };

  stopDesktop = pkgs.writeTextFile {
    name = "ollama-stop.desktop";
    destination = "/share/applications/ollama-stop.desktop";
    text = ''
      [Desktop Entry]
      Version=1.0
      Type=Application
      Name=Stop Ollama
      Comment=Stop Ollama server
      Exec=${stopScript}
      Icon=applications-development
      Categories=Development;
      Terminal=false
      StartupNotify=false
    '';
  };

  restartDesktop = pkgs.writeTextFile {
    name = "ollama-restart.desktop";
    destination = "/share/applications/ollama-restart.desktop";
    text = ''
      [Desktop Entry]
      Version=1.0
      Type=Application
      Name=Restart Ollama
      Comment=Restart Ollama server
      Exec=${restartScript}
      Icon=applications-development
      Categories=Development;
      Terminal=false
      StartupNotify=false
    '';
  };

  statusDesktop = pkgs.writeTextFile {
    name = "ollama-status.desktop";
    destination = "/share/applications/ollama-status.desktop";
    text = ''
      [Desktop Entry]
      Version=1.0
      Type=Application
      Name=Ollama Status
      Comment=Show Ollama server status
      Exec=${statusScript}
      Icon=applications-development
      Categories=Development;
      Terminal=true
      StartupNotify=false
    '';
  };

in
{
  # ========== User-сервис Ollama ==========
  systemd.user.services.ollama = {
    description = "Ollama server (user)";
    after = [ "network.target" ];
    wantedBy = [];  # Не запускать при загрузке (запускаем вручную или через ярлык)

    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.ollama-cuda}/bin/ollama serve";
      Restart = "on-failure";
      RestartSec = 5;
      # Рабочая директория — домашняя папка пользователя
      WorkingDirectory = home;
      # Переменные окружения: модели на внешнем диске
      Environment = [
        "OLLAMA_MODELS=/mnt/ai/Ollama/models"
        "OLLAMA_HOST=127.0.0.1:11434"
        "HOME=${home}"
      ];
      # Доступ к GPU (пользователь уже в группах video, render, nvidia)
      # В user-сервисах DeviceAllow не работает, но права пользователя достаточно
    };
  };

  # ========== Симлинки для .desktop и скриптов ==========
  systemd.tmpfiles.rules = [
    # Скрипты для быстрого доступа в /mnt/ai/
    (myLib.mkLink "/mnt/ai/start-ollama.sh" startScript)
    (myLib.mkLink "/mnt/ai/stop-ollama.sh" stopScript)
    (myLib.mkLink "/mnt/ai/restart-ollama.sh" restartScript)
    (myLib.mkLink "/mnt/ai/status-ollama.sh" statusScript)

    # .desktop файлы в меню KDE
    (myLib.mkLink "${home}/.local/share/applications/ollama-start.desktop"   "${startDesktop}/share/applications/ollama-start.desktop")
    (myLib.mkLink "${home}/.local/share/applications/ollama-stop.desktop"    "${stopDesktop}/share/applications/ollama-stop.desktop")
    (myLib.mkLink "${home}/.local/share/applications/ollama-restart.desktop" "${restartDesktop}/share/applications/ollama-restart.desktop")
    (myLib.mkLink "${home}/.local/share/applications/ollama-status.desktop"  "${statusDesktop}/share/applications/ollama-status.desktop")
  ];
}
