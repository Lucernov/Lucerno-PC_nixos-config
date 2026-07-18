_ :

{
  # ========== Настройка Fail2ban ==========
  services.fail2ban = {
    enable = true;                                                      # Включаем демон fail2ban
    daemonSettings = {
      DEFAULT = {
        loglevel = "INFO";                                              # Уровень логирования
      };
    };
    ignoreIP = [                                                        # IP-адреса, которые никогда не блокируются
      "127.0.0.1/8"                                                     # Локальный хост
      "::1"                                                             # Локальный хост IPv6
      "192.168.0.0/24"                                                  # Локальная сеть
    ];

    jails = {                                                           # Настройки тюрем (jails) для разных служб
      # Тюрьма для SSH
      sshd = ''
        enabled = true                                                  # Включить
        port    = ssh                                                   # Порт (ssh = 22)
        filter  = sshd                                                  # Использовать фильтр sshd
        logpath = /var/log/auth.log                                     # Путь к логу
        maxretry = 3                                                    # Максимальное количество неудачных попыток
        bantime  = 1d                                                   # Время блокировки (1 день)
        findtime = 10m                                                  # Время, за которое считаются попытки (10 минут)
        action  = nftables-set                                          # Действие (добавить IP в набор nftables)
      '';

      # Тюрьма для авторизации Nginx
      nginx-http-auth = ''
        enabled = true
        port    = http,https
        filter  = nginx-http-auth
        logpath = /var/log/nginx/error.log
        maxretry = 5
        bantime  = 1d
        findtime = 10m
        action  = nftables-set
      '';

      # Тюрьма для Postfix (почтовый сервер)
      postfix = ''
        enabled = true
        port    = smtp,ssmtp
        filter  = postfix
        logpath = /var/log/mail.log
        maxretry = 3
        bantime  = 1d
        findtime = 10m
        action  = nftables-set
      '';
    };
  };

  # ========== Настройка действия для nftables ==========
  environment.etc."fail2ban/action.d/nftables-set.conf" = {
    text = ''
      [Definition]
      actionban   = /run/current-system/sw/bin/nft add element inet f2b-table addr-set-sshd { <ip> }   # Добавить IP в набор nftables при бане
      actionunban = /run/current-system/sw/bin/nft delete element inet f2b-table addr-set-sshd { <ip> } # Удалить IP из набора при разбане
    '';
  };
}
