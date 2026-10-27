{ config, pkgs, myLib, ... }:

let
  inherit (myLib) home;
  configDir = myLib.configDirName;
in
{
  systemd.tmpfiles.rules = [
    # ── PATH для KDE Plasma (влияет на .desktop и все KDE-приложения) ──
    (myLib.mkDir "${home}/.config/plasma-workspace/env")
    (myLib.mkLink "${home}/.config/plasma-workspace/env/path.sh" (pkgs.writeText "path.sh" ''
      #!/bin/sh
      # Идемпотентное добавление ~/.local/bin в PATH.
      case ":$PATH:" in
        *":$HOME/.local/bin:"*) ;;
        *) export PATH="$HOME/.local/bin:$PATH" ;;
      esac
    ''))

    # ---------- Переопределение путей домашних папок ----------
    (myLib.mkLink "${home}/.config/user-dirs.dirs" (pkgs.writeText "user-dirs.dirs" ''
      XDG_DESKTOP_DIR="$HOME/Desktop"
      XDG_DOWNLOAD_DIR="$HOME/Загрузки"
      XDG_TEMPLATES_DIR="$HOME/Templates"
      XDG_PUBLICSHARE_DIR="$HOME/Public"
      XDG_DOCUMENTS_DIR="/mnt/docs"
      XDG_MUSIC_DIR="/mnt/music"
      XDG_PICTURES_DIR="/mnt/images"
      XDG_VIDEOS_DIR="/mnt/video"
    ''))

    # ---------- Директории ----------
    (myLib.mkDir "${home}/${configDir}")
    (myLib.mkDir "${home}/.local/bin")
    (myLib.mkDir "${home}/.local/share")
    (myLib.mkDir "${home}/.local/share/applications")
    (myLib.mkDir "${home}/.local/share/Steam/config")
    (myLib.mkDir "${home}/.config")
    (myLib.mkDir "${home}/.config/autostart")
    "d ${home}/${configDir}/secrets 0750 ${myLib.userName} ${myLib.userName} -" # 0750, поэтому оставляем как есть

    # ДИСКИ
    (myLib.mkDir "/mnt/ai")
    (myLib.mkDir "/mnt/sys_archiv")

    # ---------- Права на энергопотребление CPU ----------
    "z /sys/class/powercap/intel-rapl:*/energy_uj 0640 root powercap -"

    # ---------- Симлинки конфигов ----------
    (myLib.mkLink "${home}/.config/btop" "${home}/${configDir}/dotfiles/config/btop")
    (myLib.mkLink "${home}/.config/qmmp" "${home}/${configDir}/dotfiles/config/qmmp")
    (myLib.mkLink "${home}/.config/SocialStream" "${home}/${configDir}/dotfiles/config/SocialStream")
    (myLib.mkLink "${home}/.config/obs-studio" "${home}/${configDir}/dotfiles/config/obs-studio")
    (myLib.mkLink "${home}/.config/MangoHud" "${home}/${configDir}/dotfiles/config/MangoHud")
    (myLib.mkLink "${home}/.config/kdeglobals" "${home}/${configDir}/dotfiles/config/KDE/config_kdeglobals")
    (myLib.mkLink "${home}/.config/kglobalshortcutsrc" "${home}/${configDir}/dotfiles/config/KDE/config_kglobalshortcutsrc")
    (myLib.mkLink "${home}/.config/kwinrc" "${home}/${configDir}/dotfiles/config/KDE/config_kwinrc")
    (myLib.mkLink "${home}/.config/kxkbrc" "${home}/${configDir}/dotfiles/config/KDE/config_kxkbrc")
    (myLib.mkLink "${home}/.config/plasmarc" "${home}/${configDir}/dotfiles/config/KDE/config_plasmarc")
    (myLib.mkLink "${home}/.config/mc" "${home}/${configDir}/dotfiles/config/mc")
    (myLib.mkLink "${home}/.config/fastfetch" "${home}/${configDir}/dotfiles/config/fastfetch")
    (myLib.mkLink "${home}/.config/TeamSpeak" "${home}/${configDir}/dotfiles/config/TeamSpeak")
    (myLib.mkLink "${home}/.config/KDE" "${home}/${configDir}/dotfiles/config/KDE/KDE")

    # ---------- Kdenlive ----------
    (myLib.mkLink "${home}/.config/kdenlive-layoutsrc" "${home}/${configDir}/dotfiles/config/kdenlive/kdenlive-layoutsrc")
    (myLib.mkLink "${home}/.config/kdenliverc" "${home}/${configDir}/dotfiles/config/kdenlive/kdenliverc")
    (myLib.mkDir "${home}/.local/share/kdenlive")
    (myLib.mkLink "${home}/.local/share/kdenlive/export" "${home}/${configDir}/dotfiles/config/kdenlive/export")
    (myLib.mkLink "${home}/.local/share/kdenlive/layouts" "${home}/${configDir}/dotfiles/config/kdenlive/layouts")

    # ---------- cliamp ----------
    (myLib.mkDir "${home}/.config/cliamp")
    (myLib.mkLink "${home}/.config/cliamp/playlists" "${home}/${configDir}/dotfiles/config/cliamp/playlists")
    (myLib.mkLink "${home}/.config/cliamp/config.toml" "${home}/${configDir}/dotfiles/config/cliamp/config.toml")
    (myLib.mkLink "${home}/.config/cliamp/radio_favorites.toml" "${home}/${configDir}/dotfiles/config/cliamp/radio_favorites.toml")

    # ---------- Симлинки для приложений и данных ----------
    (myLib.mkDir "${home}/.config/AmneziaVPN.ORG")
    (myLib.mkLink "${home}/.config/AmneziaVPN.ORG/AmneziaVPN.conf" config.age.secrets."amneziavpn-conf".path)
    (myLib.mkLink "${home}/.local/bin/socialstreamninja" "/mnt/sys_archiv/pkgs/AppImages/socialstreamninja.AppImage") # v0.4.28

    # ---------- Автозапуск ----------
    (myLib.mkLink "${home}/.config/autostart/amneziavpn.desktop" (pkgs.writeText "amneziavpn.desktop" ''
      [Desktop Entry]
      Type=Application
      Name=AmneziaVPN
      Exec=amnezia-vpn
      Icon=amnezia-vpn
      X-KDE-autostart-after=panel
      StartupNotify=false
      Terminal=false
    ''))

    # ========== .desktop файлы ==========

    # --- Ярлык REAPER в меню KDE ---
    (myLib.mkLink "${home}/.local/share/applications/reaper-x11.desktop" (pkgs.writeText "reaper-x11.desktop" ''
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
    ''))

    # --- Ярлык Minion в меню KDE ---
    (myLib.mkLink "${home}/.local/share/applications/minion.desktop" (pkgs.writeText "minion.desktop" ''
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
    ''))

    # --- Ярлык QMMP в меню KDE ---
    (myLib.mkLink "${home}/.local/share/applications/org.qmmp.qmmp.desktop" (pkgs.writeText "org.qmmp.qmmp.desktop" ''
      [Desktop Entry]
      Name=Qmmp
      Exec=/run/current-system/sw/bin/qmmp %F
      Icon=qmmp
      Terminal=false
      Type=Application
      Categories=Audio;AudioVideo;
    ''))

    # --- Ярлык Ampero ---
    (myLib.mkLink "${home}/.local/share/applications/ampero2.desktop" (pkgs.writeText "ampero2.desktop" ''
      [Desktop Entry]
      Type=Application
      Name=Ampero II
      Comment=Hotone Ampero II Editor
      Exec=env WINEPREFIX="/mnt/music/MUSIC-WINE/guitar" wine "/mnt/music/MUSIC-WINE/guitar/drive_c/Program Files/Hotone/Ampero II/Ampero II.exe"
      Icon=${home}/${configDir}/dotfiles/sys-icons/icon-hotone.png
      Categories=Audio;AudioVideo;
      StartupNotify=true
      Terminal=false
    ''))

    # --- Ярлык SocialStreamNinja ---
    (myLib.mkLink "${home}/.local/share/applications/socialstreamninja.desktop" (pkgs.writeText "socialstreamninja.desktop" ''
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
    ''))

    # ----------Ярлык TeamSpeak 6 с поддержкой X11 в Wayland ----------
    (myLib.mkLink "${home}/.local/share/applications/teamspeak6.desktop" (pkgs.writeText "teamspeak6.desktop" ''
      [Desktop Entry]
      Categories=Audio;AudioVideo;Chat;Network
      Comment=TeamSpeak Voice Communication Client
      Exec=TeamSpeak --ozone-platform=x11 %F
      Icon=teamspeak6-client
      Name=TeamSpeak
      StartupWMClass=teamspeak-client
      Type=Application
      Version=1.5
    ''))
  ];
}
