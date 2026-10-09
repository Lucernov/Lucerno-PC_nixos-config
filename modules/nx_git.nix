{ config, pkgs, myLib, ... }:

let
  inherit (myLib) home;
in

{
  systemd.tmpfiles.rules = [

    "d ${home}/.config/nix 0755 ${myLib.userName} ${myLib.userName} -"
    "L+ ${home}/.git-credentials - ${myLib.userName} ${myLib.userName} - ${config.age.secrets."git-credentials".path}"
    "L+ ${home}/.config/nix/nix.conf - ${myLib.userName} ${myLib.userName} - ${pkgs.writeText "nix.conf" ''
      include ${config.age.secrets."github-token".path}
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
        # Читает ~/.git-credentials (симлинк на /run/agenix/git-credentials).
        # При попытке записать обновлённые credentials (например, при смене
        # токена) выдаст warning "unable to get credential storage lock" —
        # это безопасно, файл read-only. Credentials обновляются через:
        #   ragenix -e git-credentials.age -i ~/.config/agenix/keys.txt
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
      *.kate-swp
      .*.kate-swp
      *~
      .Trash-*
      result
    ''}"

  ];
}
