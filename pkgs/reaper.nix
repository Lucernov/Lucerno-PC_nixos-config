# pkgs/reaper.nix
{ symlinkJoin, makeWrapper, reaper, util-linux }:
symlinkJoin {
  name = "reaper-wrapped";
  paths = [ reaper ];
  buildInputs = [ makeWrapper ];
  postBuild = ''
    # Создаём обёртку, которая устанавливает переменные окружения и запускает reaper
    makeWrapper ${reaper}/bin/reaper $out/bin/reaper \
      --set GDK_BACKEND x11 \
      --run "exec ${util-linux}/bin/taskset -c 2-11"
  '';
}
