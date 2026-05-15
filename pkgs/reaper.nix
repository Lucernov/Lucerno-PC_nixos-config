# pkgs/reaper.nix
{ symlinkJoin, makeWrapper, reaper }:
symlinkJoin {
  name = "reaper-wrapped";
  paths = [ reaper ];
  buildInputs = [ makeWrapper ];
  postBuild = ''
    wrapProgram $out/bin/reaper \
      --set GDK_BACKEND x11 \
      --run "taskset -c 2-11"
  '';
}
