{ pkgs, myLib, ... }:

let
  inherit (myLib) home;
  configDir = myLib.configDirName;
in
{
  systemd.tmpfiles.rules = [

    # ---------- Переопределение путей пдомашних папок (генерируемые через pkgs.writeText) ----------
    "L+ ${home}/.config/user-dirs.dirs - lucerno lucerno - ${pkgs.writeText "user-dirs.dirs" ''
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
    "d ${home}/${configDir} 0755 lucerno lucerno -"
    "d ${home}/.local/bin 0755 lucerno lucerno -"
    "d ${home}/.local/share 0755 lucerno lucerno -"
    "d ${home}/.local/share/applications 0755 lucerno lucerno -"
    "d ${home}/.local/share/Steam/config 0755 lucerno lucerno -"
    "d ${home}/.config 0755 lucerno lucerno -"
    "d ${home}/.config/autostart 0755 lucerno lucerno -"                                      # для автозапуска
    "d ${home}/${configDir}/secrets 0750 lucerno lucerno -"

    # ДИСКИ
    "d /mnt/ai 0755 lucerno lucerno -"
    "d /mnt/sys_archiv 0755 lucerno lucerno -"

    # ---------- Права на энергопотребление CPU ----------
    "z /sys/class/powercap/intel-rapl:*/energy_uj 0640 root powercap -"

    # ---------- Симлинки конфигов (из ~/nixos-config/dotfiles/config) ----------
    "L+ ${home}/.config/nix - lucerno lucerno - ${home}/${configDir}/dotfiles/config/nix"
    "L+ ${home}/.config/btop - lucerno lucerno - ${home}/${configDir}/dotfiles/config/btop"
    "L+ ${home}/.config/qmmp - lucerno lucerno - ${home}/${configDir}/dotfiles/config/qmmp"
    "L+ ${home}/.config/SocialStream - lucerno lucerno - ${home}/${configDir}/dotfiles/config/SocialStream"
    "L+ ${home}/.config/obs-studio - lucerno lucerno - ${home}/${configDir}/dotfiles/config/obs-studio"
    "L+ ${home}/.config/MangoHud - lucerno lucerno - ${home}/${configDir}/dotfiles/config/MangoHud"
    "L+ ${home}/.config/kglobalshortcutsrc - lucerno lucerno - ${home}/${configDir}/dotfiles/config/KDE/config-kglobalshortcutsrc"

    # ---------- Симлинки для приложений и данных ----------
    "L+ ${home}/.git-credentials - lucerno lucerno - /mnt/sys_archiv/secrets/git-credentials"
    "L+ ${home}/.config/AmneziaVPN.ORG - lucerno lucerno - /mnt/sys_archiv/secrets/AmneziaVPN.ORG"
    "L+ ${home}/.local/bin/socialstreamninja - lucerno lucerno - /mnt/sys_archiv/pkgs/AppImages/socialstreamninja_linux_v0.3.128_x86_64.AppImage"

    # ---------- Автозапуск ----------
    # AmneziaVPN
    "L+ ${home}/.config/autostart/amneziavpn.desktop - lucerno lucerno - ${pkgs.writeText "amneziavpn.desktop" ''
      [Desktop Entry]
      Type=Application
      Name=AmneziaVPN
      Exec=amnezia-vpn
      Icon=amnezia-vpn
      X-KDE-autostart-after=panel
      StartupNotify=false
      Terminal=false
    ''}"

    # Конфигурационный файл Git (~/.gitconfig)
    "L+ ${home}/.gitconfig - lucerno lucerno - ${pkgs.writeText "gitconfig" ''
      [user]
        name = Lucernov
        email = jin.riv@gmail.com
      [core]
        excludesfile = ~/.gitignore
        hooksPath = ~/.git/hooks
      [credential]
        helper = store
    ''}"
    # Глобальный файл игнорирования Git (~/.gitignore)
    "L+ ${home}/.gitignore - lucerno lucerno - ${pkgs.writeText "gitignore" ''
      *.swp
      *~
      .Trash-*
      result
    ''}"

    # ---------- .desktop файлы ----------

    # --- Ярлык REAPER в меню KDE с кастомным запусском ---
    "L+ ${home}/.local/share/applications/reaper-x11.desktop - lucerno lucerno - ${pkgs.writeText "reaper-x11.desktop" ''
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
    "L+ ${home}/.local/share/applications/minion.desktop - lucerno lucerno - ${pkgs.writeText "minion.desktop" ''
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
    "L+ ${home}/.local/share/applications/org.qmmp.qmmp.desktop - lucerno lucerno - ${pkgs.writeText "org.qmmp.qmmp.desktop" ''
      [Desktop Entry]
      Name=Qmmp
      Exec=/run/current-system/sw/bin/qmmp %F
      Icon=qmmp
      Terminal=false
      Type=Application
      Categories=Audio;AudioVideo;
    ''}"

    # --- Ярлык Ampero ---
    "L+ ${home}/.local/share/applications/ampero2.desktop - lucerno lucerno - ${pkgs.writeText "ampero2.desktop" ''
      [Desktop Entry]
      Type=Application
      Name=Ampero II
      Comment=Hotone Ampero II Editor
      Exec=env WINEPREFIX="/mnt/music/wine/wine-guitar" wine "/mnt/music/wine/wine-guitar/drive_c/Program Files/Hotone/Ampero II/Ampero II.exe"
      Icon=${home}/${configDir}/dotfiles/sys-icons/icon-hotone.png
      Categories=Audio;AudioVideo;
      StartupNotify=true
      Terminal=false
    ''}"

    # --- Ярлык SocialStreamNinja приложение AppImage в меню KDE ---
    "L+ ${home}/.local/share/applications/socialstreamninja.desktop - lucerno lucerno - ${pkgs.writeText "socialstreamninja.desktop" ''
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

    # --- Ярлык Google Chrome с принудительным X11 ---
    "L+ ${home}/.local/share/applications/google-chrome.desktop - lucerno lucerno - ${pkgs.writeText "google-chrome.desktop" ''
      [Desktop Entry]
      Version=1.0
      Type=Application
      Name=Google Chrome
      Exec=google-chrome-stable --ozone-platform=x11 %U
      Icon=google-chrome
      Categories=Network;WebBrowser;
      Terminal=false
      StartupWMClass=Google-chrome-stable
    ''}"
  ];
}
