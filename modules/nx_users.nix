{ pkgs, ... }:

{
  # ========== Настройка пользователя lucerno ==========
  users.groups.lucerno = {};
  users.users.lucerno = {                                                            # Основные настройки учётной записи
    isNormalUser = true;                                                             # Обычный пользователь (не системный)
    hashedPasswordFile = "/home/lucerno/nixos-config/secrets/lucerno-password.hash"; # Файл с хешем пароля
    group = "lucerno";                                                         # Группа, к которой принадлежит пользователь
    extraGroups = [ "wheel" "networkmanager" "audio" "video" "storage" "render" ];
    shell = pkgs.zsh;                                                                # Командная оболочка по умолчанию (Zsh)
  };

  # ========== Настройка sudo ==========
  security.sudo = {
    enable = true;                                                                   # Включаем sudo
    wheelNeedsPassword = false;                                                      # Для членов группы wheel не требовать пароль. Пароль всё равно нужен для входа в систему.
  };
}
