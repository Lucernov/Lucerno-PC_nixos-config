{
  description = "Моя основная конфигурация NixOS для домашнего ПК";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    plasma-manager = {
      url = "github:nix-community/plasma-manager/trunk";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    musnix.url = "github:musnix/musnix";

    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";
  };

  outputs = inputs@{ flake-parts, nixpkgs, nixpkgs-unstable, home-manager, plasma-manager, musnix, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];

      imports = [
        # здесь можно будет добавить другие модули flake-parts (например, для home-manager)
      ];

      flake = {
        # homeConfigurations остаётся как есть (вне nixosConfigurations)
        homeConfigurations.lucerno = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          modules = [ ./home.nix ];
          extraSpecialArgs = {
            inherit inputs;
            pkgs-unstable = nixpkgs-unstable.legacyPackages.x86_64-linux;
          };
        };
      };

      perSystem = { config, pkgs, ... }: {
        # пока пусто, но можно добавить общие пакеты для devShell и т.д.
      };

      # ВАЖНО: nixosConfigurations определяется ТАК
      nixosConfigurations = {
        Lucerno-PC = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit inputs;
            pkgs-unstable = import nixpkgs-unstable {
              system = "x86_64-linux";
              config.allowUnfree = true;
            };
          };
          modules = [
            # твой новый модуль хоста (именно он импортирует старые конфиги)
            ./modules/hosts/Lucerno-PC

            # musnix
            musnix.nixosModules.musnix

            # home-manager как модуль NixOS (для бесшовной интеграции)
            home-manager.nixosModules.home-manager {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.lucerno = import ./home.nix;
              home-manager.extraSpecialArgs = {
                inherit inputs;
                pkgs-unstable = import nixpkgs-unstable {
                  system = "x86_64-linux";
                  config.allowUnfree = true;
                };
              };
            }
          ];
        };
      };
    };
}
