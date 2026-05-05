{ ... }:
{
  networking.nftables.enable = true;                 # переход на nftables
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 ];                        # Разрешаем SSH
    allowPing = true;                                # Разрешаем ping
    # Логирование подозрительных пакетов
    logRefusedConnections = false;                   # Не засорять логи
    logRefusedPackets = false;
  };
}
