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

  # ========== Таблица для fail2ban ==========
  networking.nftables.tables."f2b-table" = {
    family = "inet";
    content = ''
      # Набор для забаненных IP (общий для всех джейлов)
      set addr-set-sshd {
        type ipv4_addr
      }

      # Лимиты для защиты от DDoS
       set limit-ssh {
         type ipv4_addr
         flags dynamic, timeout
         timeout 10s
         size 1000
       }
       set limit-web {
         type ipv4_addr
         flags dynamic, timeout
         timeout 10s
         size 1000
       }
       set limit-mail {
         type ipv4_addr
         flags dynamic, timeout
         timeout 10s
         size 1000
       }

      chain fail2ban-input {
        type filter hook input priority -1; policy accept;

        # 1) Блокируем IP из набора addr-set-sshd (глобальный бан)
        ip saddr @addr-set-sshd reject with icmp port-unreachable

        # 2) Лимиты соединений
         tcp dport 22 ct state new add @limit-ssh { ip saddr timeout 10s } \
           reject with icmp port-unreachable
         tcp dport { 80, 443 } ct state new add @limit-web { ip saddr timeout 10s } \
           reject with icmp port-unreachable
         tcp dport { 25, 465, 587 } ct state new add @limit-mail { ip saddr timeout 10s } \
           reject with icmp port-unreachable
      }
    '';
  };
}
