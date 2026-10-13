# pkgs/pkg_satordist2.nix
#
# =========================================================================
# Про satordist2 — почему НЕ в pkgupdate и как проверить, не пора ли вернуть
# =========================================================================
#
# ПРИЧИНА: апстрим (yimrakhee) не ставит git-теги на релизы. Единственный
# реальный тег в репозитории — v0.6.5 на старом коммите. Версия 0.7.1
# живёт только в commit message ("v0.7.1" текстом), но тега v0.7.1 нет.
#
# nix-update для Codeberg/Gitea смотрит только теги и релизы, поэтому
# видит один v0.6.5 и пытается "обновить" 0.7.1 -> 0.6.5 (понижение!).
# Никакие --version-regex не помогают — парсить нечего.
#
# ПРОВЕРКА, НЕ ПОРА ЛИ ВЕРНУТЬ (раз в пару месяцев):
#
#   # 1. Появились ли новые git-теги у апстрима?
#   git ls-remote --tags https://codeberg.org/yimrakhee/satordist2.git
#   # Если видишь только v0.6.5 — ничего не изменилось, оставляем как есть.
#   # Если появились v0.8.0, v0.9.0 и т.п. — переходи к п.2.
#
#   # 2. Правильно ли nix-update теперь определяет версию?
#   cd ~/nixos-config
#   nix-update satordist2 --flake
#   git diff pkgs/pkg_satordist2.nix
#   # Смотри на строку "version = ...". Если версия ВЫРОСЛА или
#   # осталась на месте — всё ок, можно возвращать в pkgupdate.
#   # Если снова ПОНИЖАЕТ (0.7.1 -> 0.6.5 или новее->старее) — откати:
#   #   git checkout -- pkgs/pkg_satordist2.nix
#
#   # 3. Если п.2 показал корректный результат — добавь satordist2
#   # в список 'for pkg in ...' в блоке pkgupdate (modules/aliases.nix)
#   # и удали этот блок комментария.
#
# РУЧНОЕ ОБНОВЛЕНИЕ (пока автоматика сломана):
#   1. git clone https://codeberg.org/yimrakhee/satordist2.git /tmp/satordist2
#   2. cd /tmp/satordist2 && grep '^version' Cargo.toml
#      git rev-parse HEAD
#   3. nix run nixpkgs#nix-prefetch-git -- \
#        https://codeberg.org/yimrakhee/satordist2.git <SHA>
#   4. В pkgs/pkg_satordist2.nix обновить version, rev, hash.
#      cargoHash заменить на lib.fakeHash.
#   5. nix build .#satordist2 — Nix подскажет новый cargoHash,
#      вставить его вместо fakeHash.
#   6. sudo nixos-rebuild switch --flake .#Lucerno-PC
# =========================================================================

{ lib
, stdenv
, rustPlatform
, fetchgit
, pkg-config
, python3
, alsa-lib
, libjack2
, libX11
, libxcb
, libXcursor
, libxkbcommon
, libGL
, xcbutilwm
, xcbutilkeysyms
, xcbutilcursor
}:

rustPlatform.buildRustPackage {
  pname = "satordist2";
  version = "0.7.1";

  src = fetchgit {
    url = "https://codeberg.org/yimrakhee/satordist2.git";
    rev = "1a901656c3900a81f0c40a91ab099726dfde80f1";
    hash = "sha256-rt7qrRwXQ3UysBnOx5ODbKBsmE6tploiAvTnmRI5UdU=";
  };

  cargoHash = "sha256-DCVbFTZoUsrmP2RZoccY+zrL7aOaF0CqPLKXITNNghI=";

  nativeBuildInputs = [
    pkg-config
    python3
  ];

  buildInputs = [
    alsa-lib
    libjack2
    libX11
    libxcb
    libXcursor
    libxkbcommon
    libGL
    xcbutilwm
    xcbutilkeysyms
    xcbutilcursor
    stdenv.cc.cc.lib
  ];

  buildPhase = ''
    runHook preBuild
    cargo xtask bundle satordist2 --release
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib/clap $out/lib/vst3
    cp target/bundled/satordist2.clap $out/lib/clap/
    cp -r target/bundled/satordist2.vst3 $out/lib/vst3/
    runHook postInstall
  '';

  doCheck = false;

  meta = with lib; {
    description = "SATORDIST2 — 4-band multi-band saturator (CLAP + VST3)";
    homepage = "https://codeberg.org/yimrakhee/satordist2";
    license = licenses.gpl3Only;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ sourceTypes.fromSource ];
  };
}
