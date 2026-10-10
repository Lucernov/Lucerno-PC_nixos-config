# pkgs/pkg_teamspeak.nix
#
# Замена hotkey_helper на /bin/true: в Wayland-сессии (KDE Plasma + NVIDIA)
# оригинальный хелпер TS6 виснет при попытке зарегистрировать глобальные
# хоткеи через X11. Мы его отключаем — глобальные хоткеи TS6 работать не
# будут (используем KDE-шные), зато клиент запускается без зависаний.

{ symlinkJoin, teamspeak6-client, coreutils }:

symlinkJoin {
  name = "teamspeak6-client-wrapped";
  paths = [ teamspeak6-client ];
  nativeBuildInputs = [ coreutils ];
  postBuild = ''
    rm -f $out/share/teamspeak6-client/hotkey_helper
    ln -s ${coreutils}/bin/true $out/share/teamspeak6-client/hotkey_helper
  '';
}
