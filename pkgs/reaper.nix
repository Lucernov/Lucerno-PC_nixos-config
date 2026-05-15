# pkgs/reaper.nix
{ writeShellScriptBin, reaper }:
writeShellScriptBin "reaper" ''
  export GDK_BACKEND=x11
  exec taskset -c 2-11 ${reaper}/bin/reaper "$@"
''
