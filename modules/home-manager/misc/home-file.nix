{ ... }:
{
  # XDG пользовательские директории
  home.file = {
    ".config/user-dirs.dirs".text = ''
      XDG_DESKTOP_DIR="$HOME/Desktop"
      XDG_DOWNLOAD_DIR="$HOME/Загрузки"
      XDG_TEMPLATES_DIR="$HOME/Templates"
      XDG_PUBLICSHARE_DIR="$HOME/Public"
      XDG_DOCUMENTS_DIR="/mnt/docs"
      XDG_MUSIC_DIR="/mnt/music"
      XDG_PICTURES_DIR="/mnt/images"
      XDG_VIDEOS_DIR="/mnt/video"
    '';
    ".config/user-dirs.dirs".force = true;

    # --- Автозапуск AmneziaVPN ---
    # Создаёт .desktop-файл, который запускает AmneziaVPN при входе в KDE.
    ".config/autostart/amneziavpn.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Name=AmneziaVPN
      Exec=amnezia-vpn
      Icon=amnezia-vpn
      X-KDE-autostart-after=panel
      StartupNotify=false
      Terminal=false
    '';

    # --- Кастомный запуск REAPER с GDK_BACKEND=x11 ---
    ".local/bin/reaper".source = /home/lucerno/nixos-config/scripts/reaper;
    ".local/bin/reaper".executable = true;

    # --- Ярлык REAPER в меню KDE ---
    ".local/share/applications/reaper-x11.desktop".text = ''
      [Desktop Entry]
      Version=1.0
      Type=Application
      Name=REAPER
      Comment=ПРОСТО БОЛЬ !!!
      Exec=/home/lucerno/.local/bin/reaper %F
      Icon=cockos-reaper
      Categories=Audio;AudioVideo;
      Terminal=false
      StartupWMClass=REAPER
    '';
    ".local/share/applications/reaper-x11.desktop".force = true;

    # --- Ярлык Minion в меню KDE ---
    ".local/share/applications/minion.desktop".text = ''
      [Desktop Entry]
      Version=1.0
      Type=Application
      Name=Minion
      Comment=Управление аддонами для MMORPG
      Exec=minion
      Icon=/mnt/images/sys-icons/icon-minion.png
      Categories=Game;
      Terminal=false
      StartupWMClass=Minion
    '';
    ".local/share/applications/minion.desktop".force = true;

    # --- Ярлык QMMP ---
    ".local/bin/qmmp-wayland-fix".source = /home/lucerno/nixos-config/scripts/qmmp-wayland-fix;
    ".local/bin/qmmp-wayland-fix".executable = true;

    ".local/share/applications/org.qmmp.qmmp.desktop".text = ''
      [Desktop Entry]
      Name=Qmmp
      Exec=/home/lucerno/.local/bin/qmmp-wayland-fix %F
      Icon=qmmp
      Terminal=false
      Type=Application
      Categories=Audio;AudioVideo;
    '';
    ".local/share/applications/org.qmmp.qmmp.desktop".force = true;

    # --- Ярлык Ampero ---
    ".local/share/applications/ampero2.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Name=Ampero II
      Comment=Hotone Ampero II Editor
      Exec=env WINEPREFIX="/mnt/music/wine/wine-guitar" wine "/mnt/music/wine/wine-guitar/drive_c/Program Files/Hotone/Ampero II/Ampero II.exe"
      Icon=/home/lucerno/nixos-config/dotfiles/sys-icons/icon-hotone.png
      Categories=Audio;AudioVideo;
      StartupNotify=true
      Terminal=false
    '';
    ".local/share/applications/ampero2.desktop".force = true;
  };
}
