{ ... }:
{
  programs.git = {
    enable = true;
    package = null;
    ignores = [ "*.swp" "*~" ".Trash-*" "result" ];
    settings = {
      user = {
        name = "Lucernov";
        email = "jin.riv@gmail.com";
      };
    };
  };
}
