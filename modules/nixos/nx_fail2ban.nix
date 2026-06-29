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
        action  = iptables-multiport[name=sshd, port=ssh, protocol=tcp]
      '';
    };
    extraConfig = ''
      [DEFAULT]
      banaction = iptables-multiport
    '';
  };
}


#sudo systemctl status fail2ban
#sudo fail2ban-client status sshd
#sudo nft list ruleset | grep -A5 "fail2ban"
