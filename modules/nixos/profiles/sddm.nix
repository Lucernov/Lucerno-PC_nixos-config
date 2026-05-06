{ pkgs, ... }:

{
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };
  #services.displayManager.plasma-login-manager.enable = true;

  environment.systemPackages = [
    (pkgs.writeTextDir "share/sddm/themes/breeze/theme.conf.user" ''
      [General]
      background=${pkgs.copyPathToStore (toString ../../../dotfiles/wallpapers/Velo_01.JPG)}
    '')
  ];

  environment.sessionVariables = {
    LANG = "ru_RU.UTF-8";
    LANGUAGE = "ru_RU.UTF-8";
  };
}
