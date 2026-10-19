# modules/nx_fail2ban.nix
#
# fail2ban включён и работает, но джейлов пока нет: банить некого.
# Инфраструктура наготове — добавление нового джейла сводится к
# раскомментированию готового блока в jails ниже.
#
# ВАЖНО: действие nftables-set ссылается на набор addr-set-banned
# из nx_nftables.nix. Если переименуете набор — поправьте здесь.

_ :

{
  # ========== Настройка Fail2ban ==========
  services.fail2ban = {
    enable = true;                                                      # Включить демон fail2ban
    daemonSettings = {
      DEFAULT = {
        loglevel = "INFO";                                              # Уровень логирования
      };
    };
    ignoreIP = [                                                        # IP-адреса, которые никогда не блокируются
      "127.0.0.1/8"                                                     # Локальный хост
      "::1"                                                             # Локальный хост IPv6
      "192.168.0.0/24"                                                  # Локальная сеть (ПРОВЕРИТЬ свою подсеть: ip -4 addr)
    ];

    # ========== Джейлы (jails) ==========
    # Пусто. Каждый джейл — это блок вида:
    #
    #   <имя> = ''
    #     enabled      = true
    #     port         = <порт>
    #     filter       = <фильтр из filter.d>
    #     journalmatch = <какие записи journald смотреть>
    #     maxretry     = <попыток до бана>
    #     bantime      = <длительность бана>
    #     findtime     = <окно, за которое считаются попытки>
    #     action       = nftables-set
    #   '';
    #
    # Все джейлы скидывают забаненные IP в общий набор addr-set-banned
    # (см. nx_nftables.nix) через действие nftables-set.
    #
    # Пример для SSH — раскомментировать вместе с services.openssh.enable:
    #
    #   sshd = ''
    #     enabled      = true
    #     port         = ssh
    #     filter       = sshd
    #     journalmatch = _SYSTEMD_UNIT=sshd.service + _COMM=sshd
    #     maxretry     = 3
    #     bantime      = 1d
    #     findtime     = 10m
    #     action       = nftables-set
    #   '';
    jails = { };
  };

  # ========== Действие для nftables ==========
  # Кастомное действие: вместо стандартных ipset/iptables/mail
  # добавить/удалить IP из nftables-набора addr-set-banned.
  environment.etc."fail2ban/action.d/nftables-set.conf" = {
    text = ''
      [Definition]
      actionban   = /run/current-system/sw/bin/nft add    element inet f2b-table addr-set-banned { <ip> }
      actionunban = /run/current-system/sw/bin/nft delete element inet f2b-table addr-set-banned { <ip> }
    '';
  };
}
