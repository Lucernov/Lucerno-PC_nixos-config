{ config, pkgs, lib, ... }:

{
  services.fail2ban = {
    enable = true;
    ignoreIP = [
      "127.0.0.1/8"
      "::1"
      "192.168.0.0/24"
    ];
    jails = {
      sshd = ''
        enabled = true
        port    = ssh
        filter  = sshd
        logpath = /var/log/auth.log
        maxretry = 3
        bantime  = 1h
        findtime = 10m
        action  = nftables-set
      '';
    };
  };

  environment.etc."fail2ban/action.d/nftables-set.conf" = {
    text = ''
      [Definition]
      actionban   = /run/current-system/sw/bin/nft add element inet nixos-fw addr-set-sshd { <ip> }
      actionunban = /run/current-system/sw/bin/nft delete element inet nixos-fw addr-set-sshd { <ip> }
    '';
  };
}


#sudo systemctl status fail2ban
#sudo fail2ban-client status sshd
#sudo nft list ruleset | grep -A5 "fail2ban"
