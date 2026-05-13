{ pkgs, ... }:

{
  # ========== Настройка пользователя lucerno ==========
  users.users.lucerno = {                                                            # Основные настройки учётной записи
    isNormalUser = true;                                                             # Обычный пользователь (не системный)
    hashedPasswordFile = "/etc/nixos-password.hash";                                 # Файл с хешем пароля
    description = "lucerno";                                                         # Группа, к которой принадлежит пользователь
    # Дополнительные группы
    # wheel   – право выполнять команды через sudo
    # networkmanager – управление сетью
    # audio   – доступ к звуковым устройствам
    # video   – доступ к видеодрайверу (GPU)
    # storage – доступ к дискам и файловым системам
    extraGroups = [ "wheel" "networkmanager" "audio" "video" "storage" ];
    shell = pkgs.zsh;                                                                # Командная оболочка по умолчанию (Zsh)
  };

  # ========== Настройка sudo ==========
  security.sudo = {
    enable = true;                                                                   # Включаем sudo
    wheelNeedsPassword = false;                                                      # Для членов группы wheel не требовать пароль. Пароль всё равно нужен для входа в систему.
  };
}
