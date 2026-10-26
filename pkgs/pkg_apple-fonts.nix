# pkgs/pkg_apple-fonts.nix
#
# SF Pro (variable) + SF Pro Display Regular + New York.
#   - SF Pro variable .ttf         — все веса, все ширины (25 named instances)
#   - SF-Pro-Italic.ttf            — italic variable
#   - SF-Pro-Display-Regular.otf   — для заголовков окон KDE
#   - New York (48 .otf)           — Small/Medium/Large/ExtraLarge × все веса
#
# Всё в одном архиве dotfiles/repo/apple-fonts.tar.zst (~16 МБ),
# сжатие zstd --ultra -22 из исходных ~53 МБ.

{ lib
, stdenv
, fetchurl
, zstd
}:

stdenv.mkDerivation {
  pname = "apple-fonts-lite";
  version = "1.0";

  # Берем архив напрямую с GitHub Media (LFS-домен)
  src = fetchurl {
    url = "https://github.com/Lucernov/Lucerno-PC_nixos-config/releases/download/personal-assets-1.0/apple-fonts.tar.zst";
    hash = "sha256-B8UMmIpsIH+TSCYhc1AVnqFY6YjwrIilwBZtiZujVL4=";
  };

  nativeBuildInputs = [ zstd ];

  dontConfigure = true;
  dontBuild = true;
  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/fonts

    # --strip-components=1 убирает верхний уровень all/ из архива,
    # чтобы под $out/share/fonts/ легли папки sf-pro/ и new-york/
    zstd -d -c $src \
      | tar -xf - -C $out/share/fonts/ --strip-components=1

    # Fail-safe
    test -f $out/share/fonts/sf-pro/SF-Pro.ttf \
      || { echo "ERROR: SF-Pro.ttf не найден"; exit 1; }
    test -f $out/share/fonts/sf-pro/SF-Pro-Display-Regular.otf \
      || { echo "ERROR: SF-Pro-Display-Regular.otf не найден"; exit 1; }
    test -d $out/share/fonts/new-york \
      || { echo "ERROR: папка new-york не найдена"; exit 1; }

    runHook postInstall
  '';

  meta = with lib; {
    description = "Apple SF Pro + SF Pro Display Regular + New York (subset)";
    homepage = "https://developer.apple.com/fonts/";
    license = licenses.unfree;
    platforms = platforms.all;
    sourceProvenance = [ sourceTypes.binaryNativeCode ];
  };
}
