# Модуль для автоматического монтирования облачных дисков (Google Drive, OneDrive) через rclone
{ pkgs, myLib, ... }:

{
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
        PrivateDevices = false;
        ProtectSystem = "off";
        ProtectHome = false;
        NoNewPrivileges = false;
        ProtectKernelTunables = false;
        ProtectControlGroups = false;
        ProtectKernelLogs = false;
        RestrictNamespaces = false;
        LockPersonality = false;
        MemoryDenyWriteExecute = false;
        RestrictRealtime = false;
        RestrictSUIDSGID = false;
        PrivateTmp = false;
        SupplementaryGroups = [ "fuse" ];
        DeviceAllow = [ "/dev/fuse" ];
        DevicePolicy = "auto";
        # AmbientCapabilities = [ "CAP_SYS_ADMIN" ]; # если не поможет, раскомментируйте
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

    rclone-onedrive = {
      description = "RClone Mount for OneDrive";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        User = myLib.userName;
        Group = "users";
        Type = "simple";
        PrivateDevices = false;
        ProtectSystem = "off";
        ProtectHome = false;
        NoNewPrivileges = false;
        ProtectKernelTunables = false;
        ProtectControlGroups = false;
        ProtectKernelLogs = false;
        RestrictNamespaces = false;
        LockPersonality = false;
        MemoryDenyWriteExecute = false;
        RestrictRealtime = false;
        RestrictSUIDSGID = false;
        PrivateTmp = false;
        SupplementaryGroups = [ "fuse" ];
        DeviceAllow = [ "/dev/fuse" ];
        DevicePolicy = "auto";
        # AmbientCapabilities = [ "CAP_SYS_ADMIN" ];
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
}
