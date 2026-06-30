{ pkgs-unstable, lib, ... }:
{
  # ========== Активационные скрипты (выполняются при каждом переключении поколения home-manager) ==========
  # Создаёт символическую ссылку wine64 в ~/.local/bin, чтобы winetricks не ругался на отсутствие wine64
  home.activation.createWine64Link = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p $HOME/.local/bin
    ln -sf ${pkgs-unstable.wineWow64Packages.staging}/bin/wine $HOME/.local/bin/wine64
  '';

  # Создаёт каталог ~/.vst3 для пользовательских VST-плагинов (стандартная папка для VST3)
  home.activation.createVst3Dir = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p $HOME/.vst3
  '';

  # ========== Пользовательские файлы (конфигурация REAPER) ==========
  # Копирует библиотеку расширения SWS в папку UserPlugins REAPER (автоматически подгружается)
  home.file.".config/REAPER/UserPlugins/reaper_sws-x86_64.so".source = "${pkgs-unstable.reaper-sws-extension}/UserPlugins/reaper_sws-x86_64.so";
  # Копирует библиотеку расширения ReaPack в папку UserPlugins REAPER
  home.file.".config/REAPER/UserPlugins/reaper_reapack-x86_64.so".source = "${pkgs-unstable.reaper-reapack-extension}/UserPlugins/reaper_reapack-x86_64.so";
}
