_:

{
  xdg.configFile."autostart/amneziavpn.desktop" = {
    text = ''
      [Desktop Entry]
      Type=Application
      Name=AmneziaVPN
      Exec=amnezia-vpn
      Icon=amnezia-vpn
      X-KDE-autostart-after=panel
      StartupNotify=false
      Terminal=false
    '';
    force = true;
  };
}
