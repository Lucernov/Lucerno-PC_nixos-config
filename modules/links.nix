# modules/links.nix
{ pkgs, lib, myLib }:

let
  home = myLib.home;
  configDir = myLib.configDirName;
in
{
  # ========== Системные правила (требуют root) ==========
  systemRules = [
    "d /mnt/www-GoogleDrive 0755 lucerno users -"
    "d /mnt/www-OneDrive 0755 lucerno users -"
  ];

  # ========== Скрипт для home.activation (директории + симлинки) ==========
  activationScript = ''
    # Создание директорий внутри ~/
    mkdir -p ${home}/.local/share && chmod 755 ${home}/.local/share
    mkdir -p ${home}/.config && chmod 755 ${home}/.config
    mkdir -p ${home}/${configDir}/secrets && chmod 750 ${home}/${configDir}/secrets

    # Прямые симлинки (БЕЗ копирования в Nix store)
    ln -sfn /mnt/sys_archiv/samples/drum_sklad ${home}/drum_sklad
    ln -sfn ${home}/${configDir}/dotfiles/config/Steam/userdata ${home}/.local/share/Steam/userdata
    ln -sfn /mnt/sys_archiv/samples/vital ${home}/.local/share/vital
    ln -sfn /mnt/ai/ComfyUI ${home}/.config/comfy-ui
    ln -sfn ${home}/${configDir}/dotfiles/config/rclone ${home}/.config/rclone
    ln -sfn ${home}/${configDir}/dotfiles/config/btop ${home}/.config/btop
    ln -sfn ${home}/${configDir}/dotfiles/config/AmneziaVPN.ORG ${home}/.config/AmneziaVPN.ORG
    ln -sfn ${home}/${configDir}/dotfiles/config/obs-studio ${home}/.config/obs-studio
    ln -sfn /mnt/sys_archiv/samples/DecentSampler ${home}/.config/DecentSampler
    ln -sfn ${home}/${configDir}/dotfiles/config/REAPER ${home}/.config/REAPER
    ln -sfn ${home}/${configDir}/dotfiles/config/yabridgectl ${home}/.config/yabridgectl
    ln -sfn ${home}/${configDir}/dotfiles/config/MangoHud ${home}/.config/MangoHud
    ln -sfn /mnt/games/SteamLibrary/steamapps ${home}/.local/share/Steam/steamapps
    ln -sfn ${home}/${configDir}/dotfiles/config/KDE/config-kglobalshortcutsrc ${home}/.config/kglobalshortcutsrc
    ln -sfn ${home}/${configDir}/dotfiles/config/KDE/local-share-applications-net.local.kitten ${home}/.local/share/applications/net.local.kitten

    # Симлинк для ядер RetroArch
    mkdir -p ${home}/.config/retroarch
    ln -sfn ${config.home.path}/lib/retroarch/cores ${home}/.config/retroarch/cores
  '';
}
