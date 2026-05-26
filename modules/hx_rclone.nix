# modules/hx_rclone.nix
{ config, pkgs, ... }:

{
  # Системные сервисы (монтируются в /mnt)
  systemd.user.services.rclone-gdrive = {
    Unit = {
      Description = "RClone Mount for Google Drive";
      After = [ "network-online.target" ];
      Wants = [ "network-online.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = ''${pkgs.rclone}/bin/rclone mount gdrive: /mnt/www-GoogleDrive \
        --config=/home/lucerno/.config/rclone/rclone.conf \
        --vfs-cache-mode full \
        --allow-other \
        --allow-non-empty \
        --transfers=1 \
        --checkers=1'';
      ExecStop = "/run/current-system/sw/bin/fusermount -u /mnt/www-GoogleDrive";
      Restart = "on-failure";
      RestartSec = "5";
    };
    Install.WantedBy = [ "default.target" ];
  };

  systemd.user.services.rclone-onedrive = {
    Unit = {
      Description = "RClone Mount for OneDrive";
      After = [ "network-online.target" ];
      Wants = [ "network-online.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = ''${pkgs.rclone}/bin/rclone mount onedrive: /mnt/www-OneDrive \
        --config=/home/lucerno/.config/rclone/rclone.conf \
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
