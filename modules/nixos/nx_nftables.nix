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


    # Дополнительные команды nftables (добавляются к основному правилу)
    extraCommands = ''
      # Создаём набор для забаненных IP (если не существует)
      create set inet nixos-fw addr-set-sshd { type ipv4_addr; }
      # Создаём цепочку fail2ban с высоким приоритетом (если не существует)
      create chain inet nixos-fw fail2ban { type filter hook input priority -1; policy accept; }
      # Добавляем правило: отклонять SSH-пакеты от IP из набора
      add rule inet nixos-fw fail2ban tcp dport 22 ip saddr @addr-set-sshd reject with icmp port-unreachable
    '';
  };
}
