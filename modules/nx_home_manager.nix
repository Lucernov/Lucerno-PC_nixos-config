{ inputs, lib, myLib, ... }:

{
  # ========== Глобальные настройки Home Manager ==========
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.backupFileExtension = "backup";

  # Передаем inputs и myLib внутрь Home Manager
  home-manager.extraSpecialArgs = { inherit inputs myLib; };

  # ========== Настройки для конкретного пользователя ==========
  home-manager.users.${myLib.userName} = { ... }: {
    home.stateVersion = "26.05";

    imports = [
      inputs.plasma-manager.homeManagerModules.plasma-manager

      # Собираем все hm_-файлы из папки modules/
      (inputs.import-tree.filter (path: lib.hasPrefix "hm_" (baseNameOf path)) ./.) # Собирать все hm_-файлы из modules/
    ];
  };
}
