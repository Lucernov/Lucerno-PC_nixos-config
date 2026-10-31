# Модуль для настройки файлового сервера Samba с автобнаружением в локальной сети (для macOS и Windows)
{ lib, myLib, ... }:

{
  # ========== Создание и настройка общей папки через systemd-tmpfiles ==========
  systemd.tmpfiles.rules = lib.mkAfter [
    "d /mnt/archiv/FTP/ 0775 ${myLib.userName} ${myLib.userName} - -"
  ];

  services = {
    # ========== Samba (общий доступ к файлам по протоколу SMB) ==========
    samba = {
      enable = true;                                          # Включить сервер Samba
      openFirewall = true;                                    # Открыть порты 139, 445 в фаерволе
      nmbd.enable = false;                                    # Отключить демон NetBIOS (nmbd)
      winbindd.enable = false;                                # Отключить интеграцию в домен Active Directory (AD) Windows
      settings = {
        global = {
          "disable netbios" = "yes";                          # Отключить старый NetBIOS (для Windows‑клиентов до Windows 10)
          "workgroup" = "pautinko";                           # Рабочая группа (должна совпадать с настройками клиентов)
          "server string" = myLib.hostName;                   # Описание сервера в сети
          "netbios name" = myLib.hostName;                    # Имя сервера в NetBIOS
          "security" = "user";                                # Аутентификация через пользователей системы (гостевой доступ отдельно)
          "hosts allow" = "192.168.0. 127.0.0.1 localhost";   # Разрешить подключения из локальной сети (Никогда не выставлять порты Samba 139 и 445 напрямую в интернет)
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
          "force user" = myLib.userName;                      # Все операции выполняются от имени указанного пользователя
          "force group" = myLib.userName;                     # Группа для создаваемых файлов
        };
      };
    };

    # ========== WSDD (Web Services Dynamic Discovery) – обнаружение SMB-сервера в сети Windows ==========
    samba-wsdd = {
      enable = true;                                          # Включить службу WSDD
      openFirewall = true;                                    # Открыть порт 3702 (UDP)
    };

    # ========== Avahi (mDNS / Bonjour) – обнаружение сервера в сети macOS и Linux ==========
    avahi = {
      enable = true;                                          # Включить сервис Avahi (Zeroconf)
      nssmdns4 = true;                                        # Добавить поддержку .local доменов в NSS
      publish = {
        enable = true;                                        # Публиковать службы
        userServices = true;                                  # Публиковать пользовательские .service файлы
      };
    };
  };

}
