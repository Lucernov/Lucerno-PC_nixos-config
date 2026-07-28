# pkgs/reaper.nix
{ symlinkJoin, reaper }:

symlinkJoin {
  name = "reaper-wrapped";
  paths = [ reaper ];
  postBuild = ''
    # Перемещаем оригинальный бинарник
    mv $out/bin/reaper $out/bin/.reaper-unwrapped
    # Создаём новый скрипт-обёртку
    cat > $out/bin/reaper <<EOF
    #!/bin/sh
    export GDK_BACKEND=x11
    exec taskset -c 2-11 $out/bin/.reaper-unwrapped "\$@"
    EOF
    chmod +x $out/bin/reaper
  '';
}
