{ pkgs, ... }:
{
  users.groups.lucerno = {};
  users.users.lucerno = {
    isNormalUser = true;
    hashedPasswordFile = "/home/lucerno/nixos-config/secrets/lucerno-password.hash";
    group = "lucerno";
    extraGroups = [ "wheel" "networkmanager" "audio" "video" "storage" ];
    shell = pkgs.zsh;
  };
  # Отключаем запрос пароля для sudo для группы wheel
  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };
}
