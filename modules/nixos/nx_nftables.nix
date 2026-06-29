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

# =============================================================================
# Полезные команды для мониторинга fail2ban и nftables
# =============================================================================

# 1. Общий статус fail2ban – показывает список активных джейлов (sudo fail2ban-client status)
# 2. Статус конкретного джейла (например, sshd) – количество неудачных попыток, бан-лист (sudo fail2ban-client status sshd)
# 3. Просмотр всех правил nftables с фильтром по цепочкам fail2ban (sudo nft list ruleset | grep -A5 "fail2ban")
# 4. Просмотр всей таблицы f2b-table (наборы, цепочки, правила) (sudo nft list table inet f2b-table)
# 5. Просмотр содержимого конкретного набора (например, limit-ssh) (sudo nft list set inet f2b-table limit-ssh)
# 6. Логи fail2ban в реальном времени (Ctrl+C для выхода) (sudo journalctl -u fail2ban -f)
# 7. Просмотр списка забаненных IP в общем наборе addr-set-sshd (sudo nft list set inet f2b-table addr-set-sshd)

# -----------------------------------------------------------------------------
# Дополнительные команды для управления банами
# -----------------------------------------------------------------------------

# Вручную забанить IP (тестирование) (sudo fail2ban-client set sshd banip 192.168.1.216)
# Вручную разбанить IP (sudo fail2ban-client set sshd unbanip 192.168.1.216)
# Перезагрузить fail2ban (после изменения конфигурации) (sudo systemctl restart fail2ban)
# Показать все настройки джейла (например, действие) (sudo fail2ban-client get sshd actions)
