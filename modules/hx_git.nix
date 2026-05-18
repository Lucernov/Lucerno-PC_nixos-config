# modules/hx_git.nix
{ ... }:
{
  home.file = {
    ".gitconfig".text = ''
      [user]
        name = Lucernov
        email = jin.riv@gmail.com
      [core]
        excludesfile = ~/.gitignore
      [credential]
        helper = store
    '';
    ".gitconfig".force = true;

    ".gitignore".text = ''
      *.swp
      *~
      .Trash-*
      result
    '';
    ".gitignore".force = true;
  };
}
