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
    '';
    ".gitignore".text = ''
      *.swp
      *~
      .Trash-*
      result
    '';
  };
}
