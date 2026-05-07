{ ... }:

{
  # ========== Настройки файервола с nftables ==========
  networking.nftables.enable = true;           # Переход на nftables (современная замена iptables)
  networking.firewall = {                      # Основные настройки межсетевого экрана
    enable = true;                             # Включаем файервол
    allowedTCPPorts = [ 22 ];                  # Разрешаем входящие TCP-соединения на порт 22 (SSH)
    allowPing = true;                          # Разрешаем ICMP-запросы (ping) – полезно для диагностики сети
    logRefusedConnections = false;             # Логирование отклонённых подключений (refused connections) Отключаем, чтобы не засорять логи
    logRefusedPackets = false;                 # Логирование отклонённых пакетов (refused packets) Отключаем для снижения шума
  };
}
