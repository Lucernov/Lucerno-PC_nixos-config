# pkgs/pkg_game-wrapper64.nix
#
# Обёртка для запуска 64-битных игр через Steam с корректным GameMode.
#
# Зачем:
#   64-битные игры (Steep, Cyberpunk, большинство современных игр)
#   запускаются через Proton/Steam. gamemoderun не может найти
#   libgamemodeauto.so.0 — в NixOS она лежит в /nix/store, а не в /usr/lib,
#   и не попадает в стандартные пути поиска динамических библиотек.
#
#   Эта обёртка:
#     1. Подставляет 64-битную libgamemodeauto.so.0 через LD_PRELOAD
#        (путь резолвится Nix при сборке — хеш автоматически обновляется
#        при обновлении nixpkgs, никакого хардкода).
#     2. Запускает команду через gamemoderun — тот связывается с демоном
#        GameMode и переключает CPU governor в performance.
#
#   Отличие от pkg_game-wrapper.nix:
#     - game-wrapper     → 32-битная libgamemodeauto.so.0 (для TESO и т.п.)
#                          использует pkgsi686Linux.gamemode.lib
#     - game-wrapper64   → 64-битная libgamemodeauto.so.0 (для Steep и т.п.)
#                          использует gamemode.lib
#
# Использование в параметрах запуска Steam:
#   SteamDeck=1 PROTON_ENABLE_NVAPI=1 KWIN_XWAYLAND_FORCE_SCANOUT=1 \
#     /run/current-system/sw/bin/game-wrapper64 %command%

{ writeShellScriptBin
, gamemode
}:

writeShellScriptBin "game-wrapper64" ''
  # 64-битная libgamemodeauto.so.0 (для 64-битных игр под Proton).
  # libgamemodeauto.so.0 сама делает dlopen("libgamemode.so") — поэтому
  # каталог с ней нужно добавить ещё и в LD_LIBRARY_PATH, а не только в LD_PRELOAD.
  GAMEMODE_LIB_DIR="${gamemode.lib}/lib"
  export LD_LIBRARY_PATH="$GAMEMODE_LIB_DIR:$LD_LIBRARY_PATH"
  export LD_PRELOAD="$GAMEMODE_LIB_DIR/libgamemodeauto.so.0:$LD_PRELOAD"
  exec ${gamemode}/bin/gamemoderun "$@"
''
