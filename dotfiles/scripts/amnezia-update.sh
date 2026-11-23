#!/usr/bin/env bash
# amnezia-update.sh — обновление конфига AmneziaVPN (импорт сервера из .conf)
#
# Использование: bash ~/nixos-config/dotfiles/scripts/amnezia-update.sh
# Или алиас: amnezia-up
#
# -----------------------------------------------------------------------------
# РУЧНОЕ ОБНОВЛЕНИЕ
# 1. Бэкап и «оживление» конфига
# # бэкап текущего (обязательно -L — разыменовать симлинк)
# cp -L ~/.config/AmneziaVPN.ORG/AmneziaVPN.conf ~/amnezia-old.conf
# # Amnezia в автозапуске — закрываем
# pkill -f amnezia-vpn
# # убираем симлинк, кладём обычную записываемую копию
# rm ~/.config/AmneziaVPN.ORG/AmneziaVPN.conf
# install -m600 ~/amnezia-old.conf ~/.config/AmneziaVPN.ORG/AmneziaVPN.conf
#
# 2. Импорт сервера в AmneziaVPN
# -Запусти приложение.
# -Добавь сервер через импорт из файла конфигурации → выбери /home/lucerno/111/WARPv2_2026-11-23.conf.
# -Подключись, проверь что интернет работает через новый сервер.
# -Полностью выйди из приложения (трей → Quit) — иначе конфиг не сбросится на диск.
#
# Проверь, что файл изменился:
# stat -c '%y  %s байт' ~/.config/AmneziaVPN.ORG/AmneziaVPN.conf
#
# 3. Перешифровать секрет
# age -r age1geasjv7af2fncszc8dlxk3qx8fltg2dpnftrlk2x9pplmzadwd5s8vyywn \
#     -o ~/nixos-config/secrets/amneziavpn-conf.age \
#     ~/.config/AmneziaVPN.ORG/AmneziaVPN.conf
#
# update
# -----------------------------------------------------------------------------

set -euo pipefail

CONF="$HOME/.config/AmneziaVPN.ORG/AmneziaVPN.conf"
BACKUP="$HOME/.amnezia-backup.conf"
SECRET="$HOME/nixos-config/secrets/amneziavpn-conf.age"
PUBKEY="age1geasjv7af2fncszc8dlxk3qx8fltg2dpnftrlk2x9pplmzadwd5s8vyywn"

# ---------- 1. Проверка, что Amnezia не запущена ----------
if pgrep -f "amnezia-vpn" >/dev/null 2>&1; then
    echo "⚠  Amnezia запущена. Закрой её полностью (трей → Quit) и запусти скрипт снова."
    exit 1
fi

# ---------- 2. Разблокировка конфига ----------
if [ -L "$CONF" ]; then
    echo "🔓 Разблокирую конфиг (снимаю read-only симлинк)..."
    cp -L "$CONF" "$BACKUP"
    rm "$CONF"
    install -m600 "$BACKUP" "$CONF"
    echo "✓ Конфиг теперь writable"
    echo "  Бэкап: $BACKUP"
    echo ""
    echo "📋 Что делать дальше:"
    echo "   1. Запусти AmneziaVPN"
    echo "   2. Импортируй сервер из .conf файла"
    echo "   3. Подключись и проверь работу"
    echo "   4. Выйди из приложения (трей → Quit, НЕ просто закрыть окно!)"
    echo ""
    read -rp "⏎  Нажми Enter когда закончишь..."
else
    echo "✓ Конфиг уже writable (продолжаю)"
fi

# ---------- 3. Проверка, что конфиг изменился ----------
if [ -f "$BACKUP" ]; then
    if cmp -s "$CONF" "$BACKUP"; then
        echo "⚠  Конфиг не изменился — нечего шифровать."
        rm -f "$BACKUP"
        exit 1
    fi
    echo "✓ Конфиг изменился ($(stat -c%s "$CONF") байт)"
fi

# ---------- 4. Шифрование ----------
echo "🔐 Шифрую новый конфиг..."
age -r "$PUBKEY" -o "$SECRET" "$CONF"
echo "✓ Секрет обновлён: $SECRET"

# ---------- 5. Очистка плейнтекста ----------
if [ -f "$BACKUP" ]; then
    shred -u "$BACKUP" 2>/dev/null || rm -f "$BACKUP"
    echo "✓ Бэкап удалён"
fi

# ---------- 6. Пересборка ----------
echo ""
echo "🔨 Пересобираю систему..."
cd "$HOME/nixos-config"
sudo nixos-rebuild switch --flake .#Lucerno-PC 2>&1 | tee /tmp/rebuild.log | tail -30

echo ""
echo "✅ Готово! AmneziaVPN обновлена с новым сервером."
echo "   Конфиг снова read-only (через симлинк на /run/agenix/...)."
