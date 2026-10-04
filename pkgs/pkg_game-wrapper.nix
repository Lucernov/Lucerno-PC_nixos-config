# pkgs/pkg_game-wrapper.nix
#
# Обёртка для запуска 32-битных игр через Steam с корректным GameMode.
#
# Зачем:
#   TESO (и другие 32-битные игры) запускаются через Proton/Steam.
#   gamemoderun не может найти libgamemodeauto.so.0 — в NixOS она лежит
#   в /nix/store, а не в /usr/lib, плюс для 32-битных процессов нужна
#   именно 32-битная версия.
#
#   Эта обёртка:
#     1. Подставляет 32-битную libgamemodeauto.so.0 через LD_PRELOAD
#        (путь резолвится Nix при сборке — хеш автоматически обновляется).
#     2. Запускает команду через gamemoderun.
#
# Использование в параметрах запуска Steam:
#   SteamDeck=1 PROTON_ENABLE_NVAPI=1 KWIN_XWAYLAND_FORCE_SCANOUT=1 \
#     /run/current-system/sw/bin/game-wrapper %command%

{ writeShellScriptBin
, gamemode
, pkgsi686Linux
}:

writeShellScriptBin "game-wrapper" ''
  # 32-битная libgamemodeauto.so.0 (для 32-битных игр под Proton).
  # libgamemodeauto.so.0 сама делает dlopen("libgamemode.so") — поэтому
  # каталог с ней нужно добавить ещё и в LD_LIBRARY_PATH, а не только в LD_PRELOAD.
  GAMEMODE_LIB_DIR="${pkgsi686Linux.gamemode.lib}/lib"
  export LD_LIBRARY_PATH="$GAMEMODE_LIB_DIR:$LD_LIBRARY_PATH"
  export LD_PRELOAD="$GAMEMODE_LIB_DIR/libgamemodeauto.so.0:$LD_PRELOAD"
  exec ${gamemode}/bin/gamemoderun "$@"
''
