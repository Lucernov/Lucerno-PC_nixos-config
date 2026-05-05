{ ... }:
{
  programs.git = {
    enable = true;
    ignores = [ "*.swp" "*~" ".Trash-*" "result" ];
    settings = {
      user = {
        name = "Lucernov";
        email = "jin.riv@gmail.com";
      };
    };
  };
}
