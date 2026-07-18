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
        enabled = true
        port    = ssh
        filter  = sshd
        logpath = /var/log/auth.log
        maxretry = 3
        bantime  = 1d
        findtime = 10m
        action  = nftables-set
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
      actionban   = /run/current-system/sw/bin/nft add element inet f2b-table addr-set-sshd { <ip> }
      actionunban = /run/current-system/sw/bin/nft delete element inet f2b-table addr-set-sshd { <ip> }
    '';
  };
}
