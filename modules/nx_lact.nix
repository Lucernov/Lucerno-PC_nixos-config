# Модуль для мониторинга и настройки видеокарт (температура, частота, вентиляторы, напряжение, разгон) через LACT
{ pkgs, ... }:

{
  # ========== Сервис демона LACT ==========
  systemd.services.lactd = {
    description = "LACT Daemon";                  # Описание сервиса
    after = [ "network.target" ];                 # Запускать после того, как сеть поднята
    wantedBy = [ "multi-user.target" ];           # Автоматически запускать при загрузке системы
    serviceConfig = {
      Type = "simple";                            # Простой процесс (не разветвляется)
      ExecStart = "${pkgs.lact}/bin/lact daemon"; # Команда запуска демона LACT
      Restart = "on-failure";                     # Перезапускать при сбое
      RestartSec = "5";                           # Задержка перед перезапуском (5 секунд)
      User = "root";                              # Запускать от root (нужен доступ к оборудованию)
    };
  };

  # ========== Симлинк для NVML (чтобы LACT находил библиотеку NVIDIA) ==========
  systemd.tmpfiles.rules = [
    # Создаёт символическую ссылку /usr/lib/libnvidia-ml.so на актуальную библиотеку NVIDIA из текущего драйвера. Это нужно, чтобы LACT мог использовать NVML для мониторинга видеокарты.
    "L+ /usr/lib/libnvidia-ml.so - - - - /run/opengl-driver/lib/libnvidia-ml.so.1"
  ];
}
