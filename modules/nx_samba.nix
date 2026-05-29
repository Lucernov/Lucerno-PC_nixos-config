# modules/nx_samba.nix
# Модуль для настройки файлового сервера Samba с автобнаружением в локальной сети (для macOS и Windows)
{ config, pkgs, lib, ... }:

{
  # ========== Создание и настройка общей папки через systemd-tmpfiles ==========
  systemd.tmpfiles.rules = lib.mkAfter [
    "d /mnt/archiv/FTP/ 0775 lucerno users - -"              # Создать папку с указанными правами и владельцем
  ];

  # ========== Samba (общий доступ к файлам по протоколу SMB) ==========
  services.samba = {
    enable = true;                                          # Включаем сервер Samba
    openFirewall = true;                                    # Открываем порты 139, 445 в фаерволе
    nmbd.enable = false;                                    # Отключаем демон NetBIOS (nmbd)
    winbindd.enable = false;                                # Отключаем интеграцию в домен Active Directory (AD) Windows

    settings = {
      global = {
        "disable netbios" = "yes";                           # Отключает старый NetBIOS (для Windows‑клиентов до Windows 10)
        "workgroup" = "pautinko";                           # Рабочая группа (должна совпадать с настройками клиентов)
        "server string" = "lucerno-pc";                     # Описание сервера в сети
        "netbios name" = "lucerno-pc";                      # Имя сервера в NetBIOS
        "security" = "user";                                # Аутентификация через пользователей системы (гостевой доступ отдельно)
        "hosts allow" = "192.168.0. 127.0.0.1 localhost";   # Разрешаем подключения из локальной сети
        "guest account" = "nobody";                         # Системный аккаунт для гостей
        "map to guest" = "bad user";                        # Неопознанные пользователи считаются гостями
      };
      "shared" = {                                          # Имя шары (общей папки)
        "path" = "/mnt/archiv/FTP/";                        # Путь к папке на диске
        "browseable" = "yes";                               # Видна в списке сетевых ресурсов
        "read only" = "no";                                 # Разрешить запись
        "guest ok" = "yes";                                 # Доступ гостям без пароля
        "create mask" = "0644";                             # Права на создаваемые файлы
        "directory mask" = "0755";                          # Права на создаваемые папки
        "force user" = "lucerno";                           # Все операции выполняются от имени указанного пользователя
        "force group" = "users";                            # Группа для создаваемых файлов
      };
    };
  };

  # ========== WSDD (Web Services Dynamic Discovery) – обнаружение SMB-сервера в сети Windows ==========
  services.samba-wsdd = {
    enable = true;                                           # Включаем службу WSDD
    openFirewall = true;                                     # Открываем порт 3702 (UDP)
  };

  # ========== Avahi (mDNS / Bonjour) – обнаружение сервера в сети macOS и Linux ==========
  services.avahi = {
    enable = true;                                           # Включаем сервис Avahi (Zeroconf)
    nssmdns4 = true;                                         # Добавляем поддержку .local доменов в NSS
    publish = {
      enable = true;                                         # Публиковать службы
      userServices = true;                                   # Публиковать пользовательские .service файлы
    };
  };

}
