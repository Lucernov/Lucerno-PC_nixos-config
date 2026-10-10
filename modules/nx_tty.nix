# modules/nx_tty.nix
# Настройка TTY (виртуальных консолей)
#
# Проблема: nvidia_drm.fbdev создаёт framebuffer размером с минимальное
# разрешение среди ВСЕХ подключённых выходов (DP-1 2560x1440 + HDMI-A-1
# 1920x1080 → framebuffer 1920x1080). Из-за этого консоль занимает ~3/4
# экрана, а справа остаётся чёрная полоса
#
# Решение: после загрузки принудительно растянуть framebuffer на полное
# разрешение основного монитора через fbset
#
# Размер шрифта (16x32 → 160x45 символов) задаётся отдельно через
# kernelParams "fbcon=font:TER16x32" в modules/hardware-configuration.nix
# Оба параметра работают в паре — убирать нельзя
#
# Сам fbset устанавливается в modules/packages.nix (единый реестр пакетов)
{ pkgs, ... }:

{
  systemd.services.fbset-tty = {
    description = "Set framebuffer console resolution to 2560x1440";
    wantedBy = [ "multi-user.target" ];
    after = [ "systemd-udev-settle.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.fbset}/bin/fbset -xres 2560 -yres 1440 -match --all";
    };
  };
}
