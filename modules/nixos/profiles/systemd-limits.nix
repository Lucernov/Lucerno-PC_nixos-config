{ ... }:
{
  systemd.user.services.plasma-plasmashell = {
    overrideStrategy = "asDropin";
    serviceConfig = {
      LimitNOFILE = 16384;
      Environment = "PATH=/run/current-system/sw/bin:/etc/profiles/per-user/lucerno/bin:/nix/var/nix/profiles/default/bin:/home/lucerno/.local/bin";
    };
  };
  systemd.user.services.kwin_wayland = {
    serviceConfig.LimitNOFILE = 16384;
  };
}
