# pkgs/pkg_kate-agent-rust.nix
#
# Kate Agent (Rust) — AI-ассистент для текстового редактора Kate.
#
# ─────────────────────────────────────────────────────────────────────
# АРХИТЕКТУРА
# ─────────────────────────────────────────────────────────────────────
# Плагин разделен на две части:
#   • C++ (UI): панель чата на Qt6/KF6 (наследник KTextEditor::Plugin).
#   • Rust (Логика): сеть, JSON, асинхронность (tokio, reqwest, serde).
# Связь между ними осуществляется через FFI-мост (крейт `cxx`).
#
# ─────────────────────────────────────────────────────────────────────
# РАБОТА С OLLAMA
# ─────────────────────────────────────────────────────────────────────
# По умолчанию плагин настроен на работу с ЛОКАЛЬНОЙ Ollama:
#   URL: http://127.0.0.1:11434/api/chat
#   Модель: qwen-coder:latest
# Стриминг отключен (stream: false), контекст увеличен до 16384 токенов.
# API-ключ не требуется (пустое поле). Если понадобится внешнее API,
# настройки можно поменять через шестеренку в самом плагине Kate.
#
# Настройки (URL, API Key, System Prompt) сохраняются в:
#   ~/.config/kate-agent-rust/config.json
#
# ─────────────────────────────────────────────────────────────────────
# КАК ОБНОВИТЬ ПЛАГИН
# ─────────────────────────────────────────────────────────────────────
# Исходники лежат вне репозитория (на внешнем диске):
#   /mnt/sys_archiv/pkgs/My_Soft/kate-agent-rust/
#
# 1. Внести правки в исходники.
# 2. Зайти в nix-shell и собрать: ./cpp/deploy.sh
# 3. Упаковать бинарник:
#    tar --sort=name --mtime='@0' --owner=0 --group=0 --numeric-owner \
#        -c kateagentrust.so | zstd --ultra -22 -T0 -q -c > kateagentrust-0.1.0.tar.zst
# 4. Создать новый GitHub Release (например, kate-agent-0.1.1)
#    и прикрепить туда этот tar.zst.
# 5. Обновить `version`, `url` и `hash` в этом файле.
#    (hash получается через nix build .#kate-agent-rust).
# ─────────────────────────────────────────────────────────────────────

{ lib
, stdenv
, fetchurl
, autoPatchelfHook
, zstd
, qt6
, kdePackages
, gcc
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "kate-agent-rust";
  version = "0.1.0";

  src = fetchurl {
    url = "https://github.com/Lucernov/Lucerno-PC_nixos-config/releases/download/kate-agent-0.1.0/kateagentrust-0.1.0.tar.zst";
    hash = "sha256-q0V2gK0TjBnR5r1bqMTnBGezCtbwWwEzRuaEDl1bg4o=";
  };

  nativeBuildInputs = [ autoPatchelfHook zstd ];

  buildInputs = [
    qt6.qtbase
    kdePackages.kcoreaddons
    kdePackages.ki18n
    kdePackages.ktexteditor
    kdePackages.kxmlgui
    kdePackages.kconfigwidgets
    gcc.cc.lib
  ];

  # Плагин — это библиотека (.so), а не приложение. Запрещаем Nix оборачивать его в wrapQtAppsHook
  dontWrapQtApps = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/qt-6/plugins/kf6/ktexteditor/
    cp kateagentrust.so $out/lib/qt-6/plugins/kf6/ktexteditor/

    runHook postInstall
  '';

  meta = with lib; {
    description = "Kate plugin: AI agent with Rust backend (локальная Ollama)";
    homepage = "https://github.com/Lucernov/Lucerno-PC_nixos-config";
    license = licenses.mit;
    platforms = [ "x86_64-linux" ];
  };
})
