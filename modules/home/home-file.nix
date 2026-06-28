{ config, pkgs, myLib, ... }:
{
  # XDG пользовательские директории
  home.file = {

    # --- Переопределение путей пдомашних папок ---
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

    # --- Конфигурация Powerlevel10k ---
    ".p10k.zsh".source = ./dotfiles/config/zsh/.p10k.zsh;

    # --- Указывает количество потоков для компиляции шейдеров в Steam ---
    ".local/share/Steam/config/steam_dev.cfg".text = ''
      unShaderBackgroundProcessingThreads 16
    '';
    ".local/share/Steam/config/steam_dev.cfg".force = true;

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

    # --- Ярлык REAPER в меню KDE с кастомным запусском ---
    ".local/share/applications/reaper-x11.desktop".text = ''
      [Desktop Entry]
      Version=1.0
      Type=Application
      Name=REAPER
      Comment=ПРОСТО БОЛЬ !!!
      Exec=${pkgs.my-packages.reaper}/bin/reaper %F
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
      Icon=${myLib.home}/${myLib.configDirName}/dotfiles/sys-icons/icon-minion.png
      Categories=Game;
      Terminal=false
      StartupWMClass=Minion
    '';
    ".local/share/applications/minion.desktop".force = true;

    # --- Ярлык QMMP в меню KDE с кастомным запусском ---
    ".local/share/applications/org.qmmp.qmmp.desktop".text = ''
      [Desktop Entry]
      Name=Qmmp
      Exec=${pkgs.my-packages.qmmp}/bin/qmmp %F
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
      Icon=${myLib.home}/${myLib.configDirName}/dotfiles/sys-icons/icon-hotone.png
      Categories=Audio;AudioVideo;
      StartupNotify=true
      Terminal=false
    '';
    ".local/share/applications/ampero2.desktop".force = true;

    # --- Ярлык SocialStreamNinja приложение AppImage в меню KDE ---
    ".local/share/applications/socialstreamninja.desktop".text = ''
      [Desktop Entry]
      Version=1.0
      Type=Application
      Name=SocialStreamNinja
      Comment=Управление социальными сетями
      Exec=/mnt/sys_archiv/pkgs/AppImages/socialstreamninja_linux_v0.3.113_x86_64.AppImage
      Icon=${myLib.home}/${myLib.configDirName}/dotfiles/sys-icons/icon-SocialStreamNinja.png
      Categories=Network;
      Terminal=false
      StartupNotify=true
    '';
    ".local/share/applications/socialstreamninja.desktop".force = true;

    # --- Ярлык Google Chrome с принудительным X11 ---
    ".local/share/applications/google-chrome.desktop".text = ''
      [Desktop Entry]
      Version=1.0
      Type=Application
      Name=Google Chrome
      Exec=google-chrome-stable --ozone-platform=x11 %U
      Icon=google-chrome
      Categories=Network;WebBrowser;
      Terminal=false
      StartupWMClass=Google-chrome-stable
    '';
    ".local/share/applications/google-chrome.desktop".force = true;


    # --- Включение RT приоритета для музыки ---
    ".config/systemd/user/pipewire.service.d/99-realtime.conf".text = ''
      [Service]
      CPUSchedulingPolicy=fifo
      CPUSchedulingPriority=85
      Nice=-11
      LimitRTPRIO=89
    '';
    ".config/systemd/user/pipewire-pulse.service.d/99-realtime.conf".text = ''
      [Service]
      CPUSchedulingPolicy=fifo
      CPUSchedulingPriority=85
      Nice=-11
      LimitRTPRIO=89
    '';
    ".config/systemd/user/wireplumber.service.d/99-realtime.conf".text = ''
      [Service]
      CPUSchedulingPolicy=fifo
      CPUSchedulingPriority=85
      Nice=-11
      LimitRTPRIO=89
    '';
  };
}
