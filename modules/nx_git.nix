{ pkgs, myLib, ... }:

let
  inherit (myLib) home;
  configDir = myLib.configDirName;
in

{
  systemd.tmpfiles.rules = [

    "d ${home}/.config/nix 0755 ${myLib.userName} ${myLib.userName} -"
    "L+ ${home}/.git-credentials - ${myLib.userName} ${myLib.userName} - ${home}/${configDir}/secrets/git-credentials"
    "L+ ${home}/.config/nix/nix.conf - ${myLib.userName} ${myLib.userName} - ${pkgs.writeText "nix.conf" ''
      include ${home}/${configDir}/secrets/github-token
    ''}"

    # Конфигурационный файл Git (~/.gitconfig)
    "L+ ${home}/.gitconfig - ${myLib.userName} ${myLib.userName} - ${pkgs.writeText "gitconfig" ''
      [user]
        name = Lucernov
        email = jin.riv@gmail.com
      [core]
        excludesfile = ~/.gitignore
        hooksPath = ~/.git/hooks
      [credential]
        helper = store

      # Настройки для Git LFS
      [filter "lfs"]
        process = git-lfs filter-process
        required = true
        clean = git-lfs clean -- %f
        smudge = git-lfs smudge -- %f
    ''}"

    # Глобальный файл игнорирования Git (~/.gitignore)
    "L+ ${home}/.gitignore - ${myLib.userName} ${myLib.userName} - ${pkgs.writeText "gitignore" ''
      *.swp
      *~
      .Trash-*
      result
    ''}"

  ];
}
