{ pkgs, myLib, ... }:

let
  inherit (myLib) home;
  configDir = myLib.configDirName;
in
{
  systemd.tmpfiles.rules = [

    # ---------- Переопределение путей пдомашних папок (генерируемые через pkgs.writeText) ----------
    "L+ ${home}/.config/user-dirs.dirs - ${myLib.userName} ${myLib.userName} - ${pkgs.writeText "user-dirs.dirs" ''
      XDG_DESKTOP_DIR="$HOME/Desktop"
      XDG_DOWNLOAD_DIR="$HOME/Загрузки"
      XDG_TEMPLATES_DIR="$HOME/Templates"
      XDG_PUBLICSHARE_DIR="$HOME/Public"
      XDG_DOCUMENTS_DIR="/mnt/docs"
      XDG_MUSIC_DIR="/mnt/music"
      XDG_PICTURES_DIR="/mnt/images"
      XDG_VIDEOS_DIR="/mnt/video"
    ''}"

    # ---------- Директории ----------
    "d ${home}/${configDir} 0755 ${myLib.userName} ${myLib.userName} -"
    "d ${home}/.local/bin 0755 ${myLib.userName} ${myLib.userName} -"
    "d ${home}/.local/share 0755 ${myLib.userName} ${myLib.userName} -"
    "d ${home}/.local/share/applications 0755 ${myLib.userName} ${myLib.userName} -"
    "d ${home}/.local/share/Steam/config 0755 ${myLib.userName} ${myLib.userName} -"
    "d ${home}/.config 0755 ${myLib.userName} ${myLib.userName} -"
    "d ${home}/.config/autostart 0755 ${myLib.userName} ${myLib.userName} -"
    "d ${home}/${configDir}/secrets 0750 ${myLib.userName} ${myLib.userName} -"

    # ДИСКИ
    "d /mnt/ai 0755 ${myLib.userName} ${myLib.userName} -"
    "d /mnt/sys_archiv 0755 ${myLib.userName} ${myLib.userName} -"

    # ---------- Права на энергопотребление CPU ----------
    "z /sys/class/powercap/intel-rapl:*/energy_uj 0640 root powercap -"

    # ---------- Симлинки конфигов (из ~/nixos-config/dotfiles/config) ----------
    "L+ ${home}/.config/nix - ${myLib.userName} ${myLib.userName} - ${home}/${configDir}/dotfiles/config/nix"
    "L+ ${home}/.config/btop - ${myLib.userName} ${myLib.userName} - ${home}/${configDir}/dotfiles/config/btop"
    "L+ ${home}/.config/qmmp - ${myLib.userName} ${myLib.userName} - ${home}/${configDir}/dotfiles/config/qmmp"
    "L+ ${home}/.config/SocialStream - ${myLib.userName} ${myLib.userName} - ${home}/${configDir}/dotfiles/config/SocialStream"
    "L+ ${home}/.config/obs-studio - ${myLib.userName} ${myLib.userName} - ${home}/${configDir}/dotfiles/config/obs-studio"
    "L+ ${home}/.config/MangoHud - ${myLib.userName} ${myLib.userName} - ${home}/${configDir}/dotfiles/config/MangoHud"
    "L+ ${home}/.config/kdeglobals - ${myLib.userName} ${myLib.userName} - ${home}/${configDir}/dotfiles/config/KDE/config_kdeglobals"
    "L+ ${home}/.config/kglobalshortcutsrc - ${myLib.userName} ${myLib.userName} - ${home}/${configDir}/dotfiles/config/KDE/config_kglobalshortcutsrc"
    "L+ ${home}/.config/kwinrc - ${myLib.userName} ${myLib.userName} - ${home}/${configDir}/dotfiles/config/KDE/config_kwinrc"
    "L+ ${home}/.config/kxkbrc - ${myLib.userName} ${myLib.userName} - ${home}/${configDir}/dotfiles/config/KDE/config_kxkbrc"
    "L+ ${home}/.config/plasmarc - ${myLib.userName} ${myLib.userName} - ${home}/${configDir}/dotfiles/config/KDE/config_plasmarc"


    # ---------- Kdenlive ----------
    # Конфиги в ~/.config/
    "L+ ${home}/.config/kdenlive-layoutsrc - ${myLib.userName} ${myLib.userName} - ${home}/${configDir}/dotfiles/config/kdenlive/kdenlive-layoutsrc"
    "L+ ${home}/.config/kdenliverc - ${myLib.userName} ${myLib.userName} - ${home}/${configDir}/dotfiles/config/kdenlive/kdenliverc"
    # Директории данных в ~/.local/share/kdenlive/
    "d ${home}/.local/share/kdenlive 0755 ${myLib.userName} ${myLib.userName} -"
    "L+ ${home}/.local/share/kdenlive/export - ${myLib.userName} ${myLib.userName} - ${home}/${configDir}/dotfiles/config/kdenlive/export"
    "L+ ${home}/.local/share/kdenlive/layouts - ${myLib.userName} ${myLib.userName} - ${home}/${configDir}/dotfiles/config/kdenlive/layouts"

    # ---------- Симлинки для приложений и данных ----------
    "L+ ${home}/.config/AmneziaVPN.ORG - ${myLib.userName} ${myLib.userName} - /mnt/sys_archiv/secrets/AmneziaVPN.ORG"
    "L+ ${home}/.local/bin/socialstreamninja - ${myLib.userName} ${myLib.userName} - /mnt/sys_archiv/pkgs/AppImages/socialstreamninja_linux_v0.3.128_x86_64.AppImage"

    # ---------- Автозапуск ----------
    # AmneziaVPN
    "L+ ${home}/.config/autostart/amneziavpn.desktop - ${myLib.userName} ${myLib.userName} - ${pkgs.writeText "amneziavpn.desktop" ''
      [Desktop Entry]
      Type=Application
      Name=AmneziaVPN
      Exec=amnezia-vpn
      Icon=amnezia-vpn
      X-KDE-autostart-after=panel
      StartupNotify=false
      Terminal=false
    ''}"

    # ---------- .desktop файлы ----------

    # --- Ярлык REAPER в меню KDE с кастомным запусском ---
    "L+ ${home}/.local/share/applications/reaper-x11.desktop - ${myLib.userName} ${myLib.userName} - ${pkgs.writeText "reaper-x11.desktop" ''
      [Desktop Entry]
      Version=1.0
      Type=Application
      Name=REAPER
      Comment=ПРОСТО БОЛЬ !!!
      Exec=/run/current-system/sw/bin/reaper %F
      Icon=cockos-reaper
      Categories=Audio;AudioVideo;
      Terminal=false
      StartupWMClass=REAPER
    ''}"

    # --- Ярлык Minion в меню KDE ---
    "L+ ${home}/.local/share/applications/minion.desktop - ${myLib.userName} ${myLib.userName} - ${pkgs.writeText "minion.desktop" ''
      [Desktop Entry]
      Version=1.0
      Type=Application
      Name=Minion
      Comment=Управление аддонами для MMORPG
      Exec=minion
      Icon=${home}/${configDir}/dotfiles/sys-icons/icon-minion.png
      Categories=Game;
      Terminal=false
      StartupWMClass=Minion
    ''}"

    # --- Ярлык QMMP в меню KDE с кастомным запусском ---
    "L+ ${home}/.local/share/applications/org.qmmp.qmmp.desktop - ${myLib.userName} ${myLib.userName} - ${pkgs.writeText "org.qmmp.qmmp.desktop" ''
      [Desktop Entry]
      Name=Qmmp
      Exec=/run/current-system/sw/bin/qmmp %F
      Icon=qmmp
      Terminal=false
      Type=Application
      Categories=Audio;AudioVideo;
    ''}"

    # --- Ярлык Ampero ---
    "L+ ${home}/.local/share/applications/ampero2.desktop - ${myLib.userName} ${myLib.userName} - ${pkgs.writeText "ampero2.desktop" ''
      [Desktop Entry]
      Type=Application
      Name=Ampero II
      Comment=Hotone Ampero II Editor
      Exec=env WINEPREFIX="/mnt/music/MUSIC-WINE/guitar" wine "/mnt/music/MUSIC-WINE/guitar/drive_c/Program Files/Hotone/Ampero II/Ampero II.exe"
      Icon=${home}/${configDir}/dotfiles/sys-icons/icon-hotone.png
      Categories=Audio;AudioVideo;
      StartupNotify=true
      Terminal=false
    ''}"

    # --- Ярлык SocialStreamNinja приложение AppImage в меню KDE ---
    "L+ ${home}/.local/share/applications/socialstreamninja.desktop - ${myLib.userName} ${myLib.userName} - ${pkgs.writeText "socialstreamninja.desktop" ''
      [Desktop Entry]
      Version=1.0
      Type=Application
      Name=SocialStreamNinja
      Comment=Управление социальными сетями
      Exec=socialstreamninja
      Icon=${home}/${configDir}/dotfiles/sys-icons/icon-SocialStreamNinja.png
      Categories=Network;
      Terminal=false
      StartupNotify=true
    ''}"

    # ----------Ярлык TeamSpeak 6 с поддержкой X11 в Wayland ----------
    "L+ ${home}/.local/share/applications/teamspeak6.desktop - ${myLib.userName} ${myLib.userName} - ${pkgs.writeText "teamspeak6.desktop" ''
      [Desktop Entry]
      Categories=Audio;AudioVideo;Chat;Network
      Comment=TeamSpeak Voice Communication Client
      Exec=TeamSpeak --ozone-platform=x11 %F
      Icon=teamspeak6-client
      Name=TeamSpeak
      StartupWMClass=teamspeak-client
      Type=Application
      Version=1.5
    ''}"
  ];
}
