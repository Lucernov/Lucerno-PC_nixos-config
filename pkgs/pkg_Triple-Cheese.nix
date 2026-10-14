# pkgs/pkg_Triple-Cheese.nix
#
# TripleCheese — бесплатный комб-фильтровый синтезатор от u-he (VST3 + CLAP).
# Апстрим: https://u-he.com/products/triplecheese/
#
# Особенности упаковки u-he-плагинов:
#   1. Плагин ЖЁСТКО прописывает путь $HOME/.u-he/TripleCheese для ресурсов
#      (Data/, Presets/, Tunefiles/). Патчить бесполезно — так задумано
#      разработчиком. Решение: кладём ресурсы в $out/share/u-he/TripleCheese,
#      а в modules/nx_audio.nix создаём симлинк ~/.u-he/TripleCheese →
#      $out/share/u-he/TripleCheese через systemd.tmpfiles.
#   2. dialog.64 — отдельный бинарник для показа лицензии/сообщений.
#      Его тоже надо пропатчить через autoPatchelfHook, иначе install.sh
#      (и, возможно, сам плагин) упадёт с "cannot execute".
#   3. VST3-бандл создаём вручную:
#      $out/lib/vst3/TripleCheese.vst3/Contents/x86_64-linux/TripleCheese.so
#   4. CLAP-плагин кладём как $out/lib/clap/TripleCheese.clap
#
# Обновление версии:
#   1. Скачать новый архив с https://u-he.com/products/triplecheese/
#   2. Получить хэш: nix-prefetch-url --unpack <url>
#   3. Обновить version, url, hash ниже.

{ lib
, stdenv
, fetchurl
, autoPatchelfHook
, alsa-lib
, freetype
, fontconfig
, libX11
, libXext
, libXcursor
, libXrandr
, libXinerama
, libxcb
, xcbutil
, xcbutilkeysyms
, xcbutilcursor
, glib
, gtk3
, libxkbcommon
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "triplecheese";
  version = "1.3.0.12092";

  src = fetchurl {
    url = "https://dl.u-he.com/releases/TripleCheese_13_12092_Linux.tar.xz";
    hash = "sha256-BOoSM/1kFzdGSAyF5mLz6B0+SMEUnKQZ+JohboUPs8Q=";
  };

  nativeBuildInputs = [ autoPatchelfHook ];

  buildInputs = [
    alsa-lib
    freetype
    fontconfig
    libX11
    libXext
    libXcursor
    libXrandr
    libXinerama
    libxcb
    xcbutil
    xcbutilkeysyms
    xcbutilcursor
    glib
    gtk3
    libxkbcommon
    stdenv.cc.cc.lib
  ];

  # Архив распаковывается в TripleCheese-12092/
  sourceRoot = "TripleCheese-12092";

  installPhase = ''
    runHook preInstall

    # ── 1. Ресурсы: Data/, Presets/, Tunefiles/, Support/ ──
    # Плагин ищет их в $HOME/.u-he/TripleCheese/ — симлинк ставится
    # через systemd.tmpfiles в modules/nx_audio.nix.
    mkdir -p $out/share/u-he
    cp -r TripleCheese $out/share/u-he/

    # ── 2. VST3 ──
    # Структура: Contents/x86_64-linux/TripleCheese.so
    # (install.sh называет его TripleCheese.so, а не .64.so —
    #  это имя, которое ожидает VST3-лоадер)
    mkdir -p $out/lib/vst3/TripleCheese.vst3/Contents/x86_64-linux
    cp TripleCheese/TripleCheese.64.so \
      $out/lib/vst3/TripleCheese.vst3/Contents/x86_64-linux/TripleCheese.so

    # ── 3. CLAP ──
    # Имя должно быть TripleCheese.clap, а не .64.so
    mkdir -p $out/lib/clap
    ln -sf $out/lib/vst3/TripleCheese.vst3/Contents/x86_64-linux/TripleCheese.so \
      $out/lib/clap/TripleCheese.clap

    # ── 4. Fail-safe: проверяем, что ключевые файлы на месте ──
    if [ ! -f "$out/share/u-he/TripleCheese/TripleCheese.64.so" ]; then
      echo "ERROR: TripleCheese.64.so не найден — структура архива изменилась"
      ls -la "$out/share/u-he/TripleCheese/"
      exit 1
    fi
    if [ ! -f "$out/share/u-he/TripleCheese/dialog.64" ]; then
      echo "ERROR: dialog.64 не найден — структура архива изменилась"
      exit 1
    fi

    runHook postInstall
  '';

  meta = with lib; {
    description = "TripleCheese — comb-filter synthesizer from u-he (VST3 + CLAP)";
    homepage = "https://u-he.com/products/triplecheese/";
    license = licenses.unfreeRedistributable;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ sourceTypes.binaryNativeCode ];
  };
})
