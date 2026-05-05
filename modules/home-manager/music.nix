{ config, pkgs, pkgs-unstable, lib, ... }:
{
  home.packages = with pkgs; [
    yabridge
    yabridgectl
    winetricks                # для настройки префиксов
    coppwr
    vital                     # синтезатор FM
    surge-xt                  # синтезатор FM
    geonkick                  # синтезатор барабанов
    drumgizmo               # сэмплер барабанов (0.9.20)
    neural-amp-modeler-lv2
    dragonfly-reverb
    fretboard
  ] ++ (with pkgs-unstable; [
    wineWow64Packages.staging
    reaper
    reaper-sws-extension
    reaper-reapack-extension
  ]);

  # Устанавливаем переменную окружения для пользовательской папки VST3
  home.sessionVariables = {
    VST3_PATH = "${config.home.homeDirectory}/.vst3";
    WINEPREFIX = "/mnt/music/wine-yabridge";
  };

  # СИМВОЛИЧЕСКАЯ ССЫЛКА, ЧТОБЫ WINETRICKS НЕ РУГАЛСЯ НА ОТСУТСТВИЕ WINЕ64
  home.activation.createWine64Link = lib.hm.dag.entryAfter ["writeBoundary"] ''
    mkdir -p $HOME/.local/bin
    ln -sf ${pkgs-unstable.wineWow64Packages.staging}/bin/wine $HOME/.local/bin/wine64
  '';

  home.activation.createVst3Dir = lib.hm.dag.entryAfter ["writeBoundary"] ''
    mkdir -p $HOME/.vst3
  '';

  # Ссылка REAPER для SWS
  home.file.".config/REAPER/UserPlugins/reaper_sws-x86_64.so".source = "${pkgs-unstable.reaper-sws-extension}/UserPlugins/reaper_sws-x86_64.so";
  # Ссылка REAPER для ReaPack
  home.file.".config/REAPER/UserPlugins/reaper_reapack-x86_64.so".source = "${pkgs-unstable.reaper-reapack-extension}/UserPlugins/reaper_reapack-x86_64.so";
}
