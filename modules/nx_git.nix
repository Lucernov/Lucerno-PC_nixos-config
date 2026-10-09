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
      # credential.helper намеренно НЕ указан.
      # ~/.git-credentials — симлинк на /run/agenix/git-credentials (read-only,
      # управляется agenix). Git не может в него записывать → при попытке
      # обновления выдаёт "unable to get credential storage lock".
      # Так как актуальные credentials уже в файле, git их просто читает.

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
