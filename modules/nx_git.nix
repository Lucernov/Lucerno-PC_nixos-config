{ config, pkgs, myLib, ... }:

let
  inherit (myLib) home;
in

{
  systemd.tmpfiles.rules = [
    (myLib.mkDir "${home}/.config/nix")
    (myLib.mkLink "${home}/.git-credentials" config.age.secrets."git-credentials".path)
    (myLib.mkLink "${home}/.config/nix/nix.conf" (pkgs.writeText "nix.conf" ''
      include ${config.age.secrets."github-token".path}
    ''))

    # Конфигурационный файл Git (~/.gitconfig)
    (myLib.mkLink "${home}/.gitconfig" (pkgs.writeText "gitconfig" ''
      [user]
        name = Lucernov
        email = jin.riv@gmail.com
      [core]
        excludesfile = ~/.gitignore
        hooksPath = ~/.git/hooks
      [credential]
        # Для GET вызываем встроенный store (он парсит URL-формат).
        # Для store/erase — молча выходим, чтобы git не пытался
        # писать в read-only файл /run/agenix/git-credentials.
        helper = "!f() { if [ \"$1\" = get ]; then git credential-store --file=/run/agenix/git-credentials get; fi; exit 0; }; f"

      # Настройки для Git LFS
      [filter "lfs"]
        process = git-lfs filter-process
        required = true
        clean = git-lfs clean -- %f
        smudge = git-lfs smudge -- %f
    ''))

    # Глобальный файл игнорирования Git (~/.gitignore)
    (myLib.mkLink "${home}/.gitignore" (pkgs.writeText "gitignore" ''
      *.swp
      *.kate-swp
      .*.kate-swp
      *~
      .Trash-*
      result
    ''))
  ];
}
