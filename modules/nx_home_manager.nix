{ inputs, myLib, ... }:

{
  # ========== Глобальные настройки Home Manager ==========
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.backupFileExtension = "backup";

  # Передаем inputs и myLib внутрь Home Manager, чтобы они были доступны в конфигах
  home-manager.extraSpecialArgs = { inherit inputs myLib; };

  # ========== Настройки для конкретного пользователя ==========
  home-manager.users.${myLib.userName} = { ... }: {
    # Обязательный параметр
    home.stateVersion = "26.05";

    imports = [ inputs.plasma-manager.homeManagerModules.plasma-manager ];

    # НИКАКИХ home.packages!!!

    programs.plasma = {
      enable = true;
      # ... тут будут настройки KDE ...
    };
  };
}
