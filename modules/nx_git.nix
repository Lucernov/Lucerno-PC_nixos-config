{ pkgs, myLib, ... }:

let
  inherit (myLib) home;
in

{
  systemd.tmpfiles.rules = [

    "L+ ${home}/.git-credentials - lucerno lucerno - /mnt/sys_archiv/secrets/git-credentials"

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

      # Настройки для Git LFS
      [filter "lfs"]
        process = git-lfs filter-process
        required = true
        clean = git-lfs clean -- %f
        smudge = git-lfs smudge -- %f
    ''}"

    # Глобальный файл игнорирования Git (~/.gitignore)
    "L+ ${home}/.gitignore - lucerno lucerno - ${pkgs.writeText "gitignore" ''
      *.swp
      *~
      .Trash-*
      result
    ''}"

  ];
}
