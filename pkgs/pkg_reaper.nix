# pkgs/reaper.nix
{ symlinkJoin, reaper, stdenv, xorg, libxkbcommon, glib, cairo, pango, fontconfig, ... }:

symlinkJoin {
  name = "reaper-wrapped";
  paths = [ reaper ];
  buildInputs = [ stdenv.cc.cc.lib ];
  postBuild = ''
    # Перемещаем оригинальный бинарник
    mv $out/bin/reaper $out/bin/.reaper-unwrapped
    # Создаём новый скрипт-обёртку
    cat > $out/bin/reaper <<EOF
    #!/bin/sh
    export GDK_BACKEND=x11
    export LD_LIBRARY_PATH=/run/opengl-driver/lib:${stdenv.cc.cc.lib}/lib:${xorg.libX11}/lib:${xorg.libxcb}/lib:${libxkbcommon}/lib:${glib}/lib:${cairo}/lib:${pango}/lib:${fontconfig}/lib
    exec taskset -c 2-11 $out/bin/.reaper-unwrapped "\$@"
    EOF
    chmod +x $out/bin/reaper
  '';
}
