{ pkgs, ... }:

{
  # Сервис демона LACT
  systemd.services.lactd = {
    description = "LACT Daemon";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.lact}/bin/lact daemon";
      Restart = "on-failure";
      RestartSec = "5";
      User = "root";
    };
  };

  # Симлинк для NVML (чтобы LACT находил библиотеку NVIDIA)
  systemd.tmpfiles.rules = [
    "L+ /usr/lib/libnvidia-ml.so - - - - /run/opengl-driver/lib/libnvidia-ml.so.1"
  ];

}
