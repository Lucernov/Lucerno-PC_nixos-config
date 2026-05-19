{ config, pkgs, pkgs-unstable, inputs, lib, ... }:

{
  # НАСТРОЙКИ HOME MANAGER
  home.stateVersion = "25.11";
  home.username = "lucerno";
  home.homeDirectory = "/home/lucerno";

  home.sessionVariables = {
    VST3_PATH = "${config.home.homeDirectory}/.vst3";  # Устанавливаем переменную окружения для пользовательской папки VST3
    WINEPREFIX = "/mnt/music/wine-yabridge";
  };

  # Импорт plasma-manager
  imports = [
    ./home-file.nix

    ./hx_comfyui.nix
    ./hx_git.nix
    ./hx_kitty.nix
    ./hx_music.nix
    ./hx_plasma.nix    # настройки KDE Plasma (горячие клавиши, обои)
    ./hx_zsh.nix
  ];

  # ========== Включение модулей программ (через home-manager) ==========
  # Эти модули не только устанавливают пакеты, но и позволяют централизованно настраивать их через атрибуты (например, programs.btop.settings).
  programs.home-manager.enable = true;  # Включает Home Manager как системный модуль (управление пользовательским окружением)

  # ========== Пакеты, устанавливаемые простым способом ==========
  home.packages = with pkgs; [ ] ++ (with pkgs-unstable; [ ]);

home.activation.maskWireplumberForPlasmalogin = lib.hm.dag.entryAfter ["writeBoundary"] ''
  # Код для проверки и маскирования сервиса
  if [ -d "/run/systemd/system" ]; then
    if ! systemctl -q is-enabled wireplumber.service 2>/dev/null; then
      echo "Маскирование wireplumber.service для плавного входа в KDE..."
      systemctl mask --user wireplumber.service >/dev/null 2>&1 || true
    fi
  fi
'';
}
