{ config, pkgs, lib, ... }:

{
  services.fail2ban = {
    enable = true;
    loglevel = "INFO";   # Уровень логирования (INFO, DEBUG, WARNING, ERROR)

    ignoreIP = [
      "127.0.0.1/8"
      "::1"
      "192.168.0.0/24"
    ];

    # Явное определение фильтров (на случай, если они отсутствуют в системе)
    filters = {
      nginx-http-auth = ''
        [Definition]
        failregex = ^<HOST> - .* "GET /.* HTTP/1\.." 401 .*$
      '';
      postfix = ''
        [Definition]
        failregex = ^<HOST>.*: (?:SASL|AUTH) authentication failed.*$
      '';
    };

    jails = {
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

  # Действие для добавления IP в общий набор addr-set-sshd
  environment.etc."fail2ban/action.d/nftables-set.conf" = {
    text = ''
      [Definition]
      actionban   = /run/current-system/sw/bin/nft add element inet f2b-table addr-set-sshd { <ip> }
      actionunban = /run/current-system/sw/bin/nft delete element inet f2b-table addr-set-sshd { <ip> }
    '';
  };
}



#sudo systemctl status fail2ban
#sudo fail2ban-client status
#sudo nft list ruleset | grep -A5 "fail2ban"
#sudo nft list table inet f2b-table
#sudo nft list set inet f2b-table limit-ssh
#sudo journalctl -u fail2ban -f
