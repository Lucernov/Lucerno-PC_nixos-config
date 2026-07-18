{ pkgs, myLib, ... }:

let
  home = myLib.home;
  userName = myLib.userName;
  configDir = myLib.configDirName;

  user-dirs-content = ''
    XDG_DESKTOP_DIR="$HOME/Desktop"
    XDG_DOWNLOAD_DIR="$HOME/Загрузки"
    XDG_TEMPLATES_DIR="$HOME/Templates"
    XDG_PUBLICSHARE_DIR="$HOME/Public"
    XDG_DOCUMENTS_DIR="/mnt/docs"
    XDG_MUSIC_DIR="/mnt/music"
    XDG_PICTURES_DIR="/mnt/images"
    XDG_VIDEOS_DIR="/mnt/video"
  '';

  gitconfig-content = ''
    [user]
      name = Lucernov
      email = jin.riv@gmail.com
    [core]
      excludesfile = ~/.gitignore
      hooksPath = ~/.git/hooks
    [credential]
      helper = store
  '';

  gitignore-content = ''
    *.swp
    *~
    .Trash-*
    result
  '';

  steam-dev-content = ''
    unShaderBackgroundProcessingThreads 16
  '';

  toggle-kitty-content = ''
    #!${pkgs.bash}/bin/bash
    if ${pkgs.kitty}/bin/kitty @ ls 2>/dev/null | grep -q "quick-access"; then
        ${pkgs.kitty}/bin/kitty @ close-window --match title:"quick-access"
    else
        ${pkgs.kitty}/bin/kitten quick-access-terminal
    fi
  '';

  # .desktop файлы
  reaperDesktop = ''
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
  '';

  minionDesktop = ''
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
  '';

  qmmpDesktop = ''
    [Desktop Entry]
    Name=Qmmp
    Exec=/run/current-system/sw/bin/qmmp %F
    Icon=qmmp
    Terminal=false
    Type=Application
    Categories=Audio;AudioVideo;
  '';

  amperoDesktop = ''
    [Desktop Entry]
    Type=Application
    Name=Ampero II
    Comment=Hotone Ampero II Editor
    Exec=env WINEPREFIX="/mnt/music/wine/wine-guitar" wine "/mnt/music/wine/wine-guitar/drive_c/Program Files/Hotone/Ampero II/Ampero II.exe"
    Icon=${home}/${configDir}/dotfiles/sys-icons/icon-hotone.png
    Categories=Audio;AudioVideo;
    StartupNotify=true
    Terminal=false
  '';

  socialstreamDesktop = ''
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
  '';

  chromeDesktop = ''
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

  kittenDesktop = ''
    [Desktop Entry]
    Type=Application
    Name=Kitten
    Exec=/run/current-system/sw/bin/kitten %F
    Icon=org.nixos.kitten
    Categories=Network;
    Terminal=false
    StartupNotify=true
  '';

in
{
  systemd.tmpfiles.rules = [
    # Создание директорий
    "d ${home}/.local/share/applications 0755 ${userName} ${userName} -"
    "d ${home}/.local/bin 0755 ${userName} ${userName} -"
    "d ${home}/.local/share/Steam/config 0755 ${userName} ${userName} -"

    # user-dirs.dirs
    "f ${home}/.config/user-dirs.dirs 0644 ${userName} ${userName} - ${pkgs.writeText "user-dirs.dirs" user-dirs-content}"
    # gitconfig
    "f ${home}/.gitconfig 0644 ${userName} ${userName} - ${pkgs.writeText "gitconfig" gitconfig-content}"
    # gitignore
    "f ${home}/.gitignore 0644 ${userName} ${userName} - ${pkgs.writeText "gitignore" gitignore-content}"
    # steam_dev.cfg
    "f ${home}/.local/share/Steam/config/steam_dev.cfg 0644 ${userName} ${userName} - ${pkgs.writeText "steam_dev.cfg" steam-dev-content}"
    # toggle-kitty
    "f ${home}/.local/bin/toggle-kitty 0755 ${userName} ${userName} - ${pkgs.writeText "toggle-kitty" toggle-kitty-content}"
    # .desktop файлы
    "f ${home}/.local/share/applications/reaper-x11.desktop 0644 ${userName} ${userName} - ${pkgs.writeText "reaper-x11.desktop" reaperDesktop}"
    "f ${home}/.local/share/applications/minion.desktop 0644 ${userName} ${userName} - ${pkgs.writeText "minion.desktop" minionDesktop}"
    "f ${home}/.local/share/applications/org.qmmp.qmmp.desktop 0644 ${userName} ${userName} - ${pkgs.writeText "org.qmmp.qmmp.desktop" qmmpDesktop}"
    "f ${home}/.local/share/applications/ampero2.desktop 0644 ${userName} ${userName} - ${pkgs.writeText "ampero2.desktop" amperoDesktop}"
    "f ${home}/.local/share/applications/socialstreamninja.desktop 0644 ${userName} ${userName} - ${pkgs.writeText "socialstreamninja.desktop" socialstreamDesktop}"
    "f ${home}/.local/share/applications/google-chrome.desktop 0644 ${userName} ${userName} - ${pkgs.writeText "google-chrome.desktop" chromeDesktop}"
    "f ${home}/.local/share/applications/net.local.kitten.desktop 0644 ${userName} ${userName} - ${pkgs.writeText "net.local.kitten.desktop" kittenDesktop}"
  ];
}
