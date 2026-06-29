{ config, pkgs, lib, ... }:

{
  # ========== Настройки файервола с nftables ==========
  networking.nftables.enable = true;          # Включаем nftables (у вас уже есть)
  networking.firewall = {                     # Основные настройки межсетевого экрана
    enable = true;                            # Включаем файервол
    allowedTCPPorts = [ 22 ];                 # Разрешаем входящие TCP-соединения на порт 22 (SSH)
    allowPing = false;                        # Отключить ICMP-запросы (ping)
    logRefusedConnections = false;            # Логирование отклонённых подключений отключаем
    logRefusedPackets = false;                # Логирование отклонённых пакетов отключаем
  };

  # Добавляем правила в таблицу f2b-table (создаётся fail2ban)
  networking.nftables.tables."f2b-table" = {
    family = "inet";
    content = ''
      set addr-set-sshd {
        type ipv4_addr
      }
      chain fail2ban-input {
        type filter hook input priority -1; policy accept;
        tcp dport 22 ip saddr @addr-set-sshd reject with icmp port-unreachable
      }
    '';
  };
}
