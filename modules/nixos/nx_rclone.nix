# Модуль home-manager для настройки автоматического монтирования облачных дисков (Google Drive, OneDrive) через rclone
{ pkgs, myLib, ... }:

{
  # ========== Сервис монтирования Google Drive ==========
  systemd.services = {
    rclone-gdrive = {
      description = "RClone Mount for Google Drive";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        User = myLib.userName;
        Group = "users";
        Type = "simple";
        SupplementaryGroups = [ "fuse" ];
        ExecStart = ''${pkgs.rclone}/bin/rclone mount gdrive: /mnt/www-GoogleDrive \
          --config=${myLib.home}/.config/rclone/rclone.conf \
          --vfs-cache-mode full \
          --allow-other \
          --allow-non-empty \
          --transfers=1 \
          --checkers=1'';
        ExecStop = "/run/current-system/sw/bin/fusermount -u /mnt/www-GoogleDrive";
        Restart = "on-failure";
        RestartSec = 5;
      };
    };

    # ========== Сервис монтирования OneDrive ==========
    rclone-onedrive = {
      description = "RClone Mount for OneDrive";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        User = myLib.userName;
        Group = "users";
        Type = "simple";
        SupplementaryGroups = [ "fuse" ];
        ExecStart = ''${pkgs.rclone}/bin/rclone mount onedrive: /mnt/www-OneDrive \
          --config=${myLib.home}/.config/rclone/rclone.conf \
          --vfs-cache-mode full \
          --allow-other \
          --allow-non-empty \
          --transfers=1 \
          --checkers=1'';
        ExecStop = "/run/current-system/sw/bin/fusermount -u /mnt/www-OneDrive";
        Restart = "on-failure";
        RestartSec = 5;
      };
    };
  };

  # инструкция обновления токена для гуглдрайва если что туточки ../dotfiles/config/rclone/обновление токена гуглдрайва.txt
}
