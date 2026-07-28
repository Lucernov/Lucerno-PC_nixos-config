# pkgs/reaper.nix
{ symlinkJoin, reaper, stdenv, libX11, libxcb, xcb-util, xcb-util-cursor, xcb-util-xkb, libxkbcommon, glib, cairo, pango, fontconfig, ... }:

symlinkJoin {
  name = "reaper-wrapped";
  paths = [ reaper ];
  buildInputs = [ stdenv.cc.cc.lib ];
  postBuild = ''
    mv $out/bin/reaper $out/bin/.reaper-unwrapped
    cat > $out/bin/reaper <<EOF
    #!/bin/sh
    export GDK_BACKEND=x11
    export LD_LIBRARY_PATH=/run/opengl-driver/lib:${stdenv.cc.cc.lib}/lib:${libX11}/lib:${libxcb}/lib:${xcb-util}/lib:${xcb-util-cursor}/lib:${xcb-util-xkb}/lib:${libxkbcommon}/lib:${glib}/lib:${cairo}/lib:${pango}/lib:${fontconfig}/lib
    exec taskset -c 2-11 $out/bin/.reaper-unwrapped "\$@"
    EOF
    chmod +x $out/bin/reaper
  '';
}
