# Модуль home-manager для настройки автоматического монтирования облачных дисков (Google Drive, OneDrive) через rclone
{ pkgs, myLib, ... }:

{
  # ========== Сервис монтирования Google Drive ==========
  # Запускается от пользователя, монтирует диск в /mnt/www-GoogleDrive
  systemd.user.services.rclone-gdrive = {
    Unit = {
      Description = "RClone Mount for Google Drive";                                  # Описание сервиса
      After = [ "network-online.target" ];                                            # Запускать после того, как сеть поднята
      Wants = [ "network-online.target" ];                                            # Желательно дождаться готовности сети
    };
    Service = {
      Type = "simple";                                                                # Простой процесс (не разветвляется)
      ExecStart = ''${pkgs.rclone}/bin/rclone mount gdrive: /mnt/www-GoogleDrive \
        --config=${myLib.home}/.config/rclone/rclone.conf \
        # Полное кэширование файлов
        --vfs-cache-mode full \
        # Разрешить доступ другим пользователям
        --allow-other \
        # Разрешить монтирование в непустую папку
        --allow-non-empty \
        # Один параллельный поток передачи
        --transfers=1 \
        # Один поток проверки
        --checkers=1'';
      ExecStop = "/run/current-system/sw/bin/fusermount -u /mnt/www-GoogleDrive";     # Команда размонтирования
      Restart = "on-failure";                                                         # Перезапускать при сбое
      RestartSec = "5";                                                               # Ждать 5 секунд перед перезапуском
    };
    Install.WantedBy = [ "default.target" ];                                          # Автоматически запускать при старте пользовательской сессии
  };

  # ========== Сервис монтирования OneDrive ==========
  # Запускается от пользователя, монтирует диск в /mnt/www-OneDrive
  systemd.user.services.rclone-onedrive = {
    Unit = {
      Description = "RClone Mount for OneDrive";
      After = [ "network-online.target" ];
      Wants = [ "network-online.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = ''${pkgs.rclone}/bin/rclone mount onedrive: /mnt/www-OneDrive \
        --config=${myLib.home}/.config/rclone/rclone.conf \
        --vfs-cache-mode full \
        --allow-other \
        --allow-non-empty \
        --transfers=1 \
        --checkers=1'';
      ExecStop = "/run/current-system/sw/bin/fusermount -u /mnt/www-OneDrive";
      Restart = "on-failure";
      RestartSec = "5";
    };
    Install.WantedBy = [ "default.target" ];
  };

  # инструкция обновления токена для гуглдрайва если что туточки ../dotfiles/config/rclone/обновление токена гуглдрайва.txt
}
