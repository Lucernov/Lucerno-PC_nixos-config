# Модуль для автоматического монтирования облачных дисков (Google Drive, OneDrive) через rclone
{ pkgs, myLib, ... }:

let
  inherit (myLib) home;
in

{
  # ========== Настройки FUSE для rclone ==========
  programs.fuse = {
    enable = true;                                                                  # Включает поддержку FUSE в системе
    userAllowOther = true;                                                          # Разрешает опцию allow_other для обычных пользователей
    mountMax = 1000;                                                                # Максимальное количество FUSE-монтирований на пользователя
  };

  # ========== Правила tmpfiles для папок монтирования ==========
  systemd.tmpfiles.rules = [
    "d /mnt/www-GoogleDrive 0755 lucerno users -"
    "d /mnt/www-OneDrive 0755 lucerno users -"
    "L+ ${home}/.config/rclone - lucerno lucerno - /mnt/sys_archiv/secrets/rclone"
  ];

  systemd.services = {
    # ========== Сервис монтирования Google Drive ==========
    rclone-gdrive = {
      description = "RClone Mount for Google Drive";                                # Описание сервиса
      after = [ "network-online.target" ];                                          # Запускать после того, как сеть полностью поднята (с доступом в интернет)
      wants = [ "network-online.target" ];                                          # Желательно дождаться готовности сети
      wantedBy = [ "multi-user.target" ];                                           # Автоматически запускать при загрузке системы
      serviceConfig = {
        User = myLib.userName;                                                      # Запускать от имени пользователя lucerno
        Group = "users";                                                            # Группа users (стандартная для обычных пользователей)
        Type = "simple";                                                            # Простой процесс (не разветвляется)

        # ---------- Отключение ограничений systemd для работы с FUSE ----------
        PrivateDevices = false;                                                     # Разрешить доступ к устройствам (/dev/fuse)
        ProtectSystem = "off";                                                      # Отключить защиту системных каталогов (необходимо для монтирования)
        ProtectHome = false;                                                        # Разрешить доступ к домашней папке (нужен конфиг rclone)
        NoNewPrivileges = false;                                                    # Разрешить процессу получать новые привилегии (CAP_SYS_ADMIN)
        PrivateMounts = false;                                                      # Не изолировать точки монтирования (нужно для FUSE)
        MountFlags = "shared";                                                      # Сделать монтирования разделяемыми (необходимо для FUSE)
        SupplementaryGroups = [ "fuse" ];                                           # Добавить группу fuse для доступа к /dev/fuse
        DeviceAllow = [ "/dev/fuse" ];                                              # Явно разрешить доступ к устройству FUSE
        AmbientCapabilities = [ "CAP_SYS_ADMIN" ];                                  # Дать процессу возможность монтировать (нужно для FUSE)

        # ---------- Команда запуска rclone ----------
        ExecStart = ''${pkgs.rclone}/bin/rclone mount gdrive: /mnt/www-GoogleDrive \
          --config=${myLib.home}/.config/rclone/rclone.conf \
          --vfs-cache-mode full \
          --allow-other \
          --allow-non-empty \
          --transfers=1 \
          --checkers=1'';

        ExecStop = "/run/current-system/sw/bin/fusermount -u /mnt/www-GoogleDrive"; # Команда размонтирования
        Restart = "on-failure";                                                     # Перезапускать при сбое
        RestartSec = 5;                                                             # Задержка перед перезапуском (5 секунд)
      };
    };

    # ========== Сервис монтирования OneDrive ==========
    rclone-onedrive = {
      description = "RClone Mount for OneDrive";                                    # Описание сервиса
      after = [ "network-online.target" ];                                          # Запускать после поднятия сети
      wants = [ "network-online.target" ];                                          # Желательно дождаться сети
      wantedBy = [ "multi-user.target" ];                                           # Автозапуск при загрузке
      serviceConfig = {
        User = myLib.userName;                                                      # Запускать от пользователя lucerno
        Group = "users";                                                            # Группа users
        Type = "simple";                                                            # Простой процесс

        # ---------- Отключение ограничений systemd для работы с FUSE ----------
        PrivateDevices = false;                                                     # Разрешить доступ к устройствам (/dev/fuse)
        ProtectSystem = "off";                                                      # Отключить защиту системных каталогов (необходимо для монтирования)
        ProtectHome = false;                                                        # Разрешить доступ к домашней папке (нужен конфиг rclone)
        NoNewPrivileges = false;                                                    # Разрешить процессу получать новые привилегии (CAP_SYS_ADMIN)
        PrivateMounts = false;                                                      # Не изолировать точки монтирования (нужно для FUSE)
        MountFlags = "shared";                                                      # Сделать монтирования разделяемыми (необходимо для FUSE)
        SupplementaryGroups = [ "fuse" ];                                           # Добавить группу fuse для доступа к /dev/fuse
        DeviceAllow = [ "/dev/fuse" ];                                              # Явно разрешить доступ к устройству FUSE
        AmbientCapabilities = [ "CAP_SYS_ADMIN" ];                                  # Дать процессу возможность монтировать (нужно для FUSE)

        # ---------- Команда запуска rclone ----------
        ExecStart = ''${pkgs.rclone}/bin/rclone mount onedrive: /mnt/www-OneDrive \
          --config=${myLib.home}/.config/rclone/rclone.conf \
          --vfs-cache-mode full \
          --allow-other \
          --allow-non-empty \
          --transfers=1 \
          --checkers=1'';

        ExecStop = "/run/current-system/sw/bin/fusermount -u /mnt/www-OneDrive";   # Команда размонтирования
        Restart = "on-failure";                                                    # Перезапускать при сбое
        RestartSec = 5;                                                            # Задержка перед перезапуском (5 секунд)
      };
    };
  };
}

#                    --config=${myLib.home}/.config/rclone/rclone.conf \           # Путь к конфигурационному файлу rclone
#                    --vfs-cache-mode full \                                       # Полное кэширование файлов (улучшает производительность)
#                    --allow-other \                                               # Разрешить доступ к монтированию другим пользователям
#                    --allow-non-empty \                                           # Разрешить монтирование в непустую папку
#                    --transfers=1 \                                               # Один параллельный поток передачи (для стабильности)
#                    --checkers=1'';                                               # Один поток проверки (для стабильности)
