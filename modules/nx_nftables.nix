_:

{
  # ========== Настройки файервола с nftables ==========
  networking = {
    nftables.enable = true;                     # Включить nftables
    firewall = {                                # Основные настройки межсетевого экрана
      enable = true;                            # Включить файервол
      allowedTCPPorts = [  ];                   # Входящие TCP-соединения отключены
      allowedUDPPorts = [                       # Входящие UDP-соединения
        10999                                   # DST main game
        11000                                   # DST caves shard
        8766                                    # DST Steam query
        27016                                   # UDP Steam master server (для появления в списке серверов)
      ];
      allowPing = false;                        # Отключить ICMP-запросы (ping)
      logRefusedConnections = false;            # Логирование отклонённых подключений отключаем
      logRefusedPackets = false;                # Логирование отклонённых пакетов отключаем
      checkReversePath = false;
    };

    # ========== Таблица для fail2ban ==========
    # Инфраструктура готова к наполнению, но джейлов пока нет (см. nx_fail2ban.nix).
    # Один общий набор addr-set-banned — все джейлы (SSH, nginx, что угодно)
    # будут скидывать забаненные IP сюда. Цепочка reject'ит любой трафик
    # с этих адресов, независимо от порта.
    #
    # Когда понадобится включить SSH:
    #   1. Добавить 22 в allowedTCPPorts выше.
    #   2. Добавить services.openssh.enable = true; в packages.nix.
    #   3. Раскомментировать sshd-джейл в nx_fail2ban.nix.
    nftables.tables."f2b-table" = {
      family = "inet";
      content = ''
        # Общий набор забаненных IP (IPv4).
        # fail2ban добавляет/удаляет элементы через действие nftables-set
        # (см. environment.etc."fail2ban/action.d/nftables-set.conf").
        set addr-set-banned {
          type ipv4_addr
        }

        # Цепочка с prio -1 идёт ДО основного firewall (prio 0),
        # поэтому забаненные пакеты отсекаются первыми.
        chain fail2ban-input {
          type filter hook input priority -1; policy accept;

          ip saddr @addr-set-banned reject with icmp port-unreachable
        }
      '';
    };
  };
}

# =============================================================================
# Полезные команды для мониторинга fail2ban и nftables
# =============================================================================

# 1. Общий статус fail2ban – показывает список активных джейлов
#    sudo fail2ban-client status
#
# 2. Статус конкретного джейла (например, sshd) – количество неудачных попыток, бан-лист
#    sudo fail2ban-client status sshd
#
# 3. Просмотр всех правил nftables с фильтром по цепочкам fail2ban
#    sudo nft list ruleset | grep -A5 "fail2ban"
#
# 4. Просмотр всей таблицы f2b-table (наборы, цепочки, правила)
#    sudo nft list table inet f2b-table
#
# 5. Просмотр списка забаненных IP в общем наборе addr-set-banned
#    sudo nft list set inet f2b-table addr-set-banned
#
# 6. Логи fail2ban в реальном времени (Ctrl+C для выхода)
#    sudo journalctl -u fail2ban -f

# -----------------------------------------------------------------------------
# Управление банами вручную (для отладки)
# -----------------------------------------------------------------------------

# Забанить IP:
#   sudo fail2ban-client set <jail> banip 192.168.1.216
#
# Разбанить IP:
#   sudo fail2ban-client set <jail> unbanip 192.168.1.216
#
# Или напрямую через nftables (минуя fail2ban):
#   sudo nft add    element inet f2b-table addr-set-banned { 192.168.1.216 }
#   sudo nft delete element inet f2b-table addr-set-banned { 192.168.1.216 }
#
# Перезагрузить fail2ban (после изменения конфигурации):
#   sudo systemctl restart fail2ban
#
# Показать все настройки джейла:
#   sudo fail2ban-client get <jail> actions
