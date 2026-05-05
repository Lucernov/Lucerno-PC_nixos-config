{ pkgs, ... }:
{
  home.packages = with pkgs; [ kitty ];

  xdg.configFile."kitty/kitty.conf".text = ''
  # Открыть новую вкладку (в текущей рабочей директории)
  map ctrl+shift+t new_tab_with_cwd

  # Закрыть текущую вкладку
  map ctrl+shift+q close_tab

  # (Опционально) Переключение между вкладками
  map ctrl+shift+right next_tab
  map ctrl+shift+left  previous_tab

  # (Опционально) Привязать Meta (Win) + W для закрытия вкладки (как в браузере)
  map super+w close_tab
  '';

  xdg.configFile."kitty/quick-access-terminal.conf".text = ''
    size = 70% 50%
    position = center, center
    background_opacity = 0.85
    hide_window_decorations = yes
    confirm_os_window_close = 0
    foreground #eceff4
    background #2e3440
  '';

  home.file.".local/bin/toggle-kitty".source = /home/lucerno/nixos-config/scripts/toggle-kitty.sh;
  home.file.".local/bin/toggle-kitty".executable = true;

  systemd.user.services.kitty-quick = {
    Unit.Description = "Kitty Quick Access";
    Service.ExecStart = "${pkgs.kitty}/bin/kitten quick-access-terminal";
    Install.WantedBy = [ "graphical-session.target" ];
  };

  home.file.".config/autostart/kitty-quick-access.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=Kitty Quick Access
    Exec=${pkgs.kitty}/bin/kitten quick-access-terminal
    Icon=kitty
    StartupNotify=false
    Terminal=false
    X-KDE-autostart-after=panel
  '';
}
