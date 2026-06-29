{ config, pkgs, lib, ... }:

{
  services.fail2ban = {
    enable = true;
    # Так как у вас включён nftables, указываем бэкенд
    backend = "nftables";
    # Игнорируем локальные адреса (чтобы не забанить себя)
    ignoreIP = [
        "127.0.0.1/8"     # localhost IPv4
        "::1"             # localhost IPv6
        "192.168.0.0/24"  # локальная сеть (если маска /24)
        # "192.168.0.0/16"  # если вся сеть 192.168.*.*
    ];

    # Определяем джейлы (правила)
    jails = {
      # SSH (основной)
      sshd = ''
        enabled = true
        port    = ssh
        filter  = sshd
        logpath = /var/log/auth.log
        maxretry = 3
        bantime  = 1h
        findtime = 10m
      '';
      # Можно добавить другие, например, для веб-сервера, если он есть
      # nginx-http-auth = ''
      #   enabled = true
      #   port    = http,https
      #   filter  = nginx-http-auth
      #   logpath = /var/log/nginx/error.log
      #   maxretry = 5
      #   bantime  = 1d
      # '';
    };
  };
}
