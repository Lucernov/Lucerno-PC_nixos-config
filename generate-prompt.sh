#!/usr/bin/env bash

# Скрипт для генерации файла с содержимым конфигурации NixOS
# Путь: /home/lucerno/nixos-config/generate-prompt.sh

# Переходим в директорию скрипта
cd "$(dirname "$0")" || exit 1

# Выходной файл
OUTPUT_FILE="$HOME/Promt(Lucerno-PC).txt"

echo "Генерация файла $OUTPUT_FILE..."

# Создаем/перезаписываем файл
> "$OUTPUT_FILE"

# Функция для добавления заголовка и содержимого файла
add_section() {
    local title="$1"
    local source_file="$2"

    # Добавляем заголовок
    echo "$title" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"

    # Добавляем содержимое файла, если он существует и читаем
    if [[ -f "$source_file" && -r "$source_file" ]]; then
        cat "$source_file" >> "$OUTPUT_FILE"
    else
        echo "# ОШИБКА: Файл $source_file не найден или недоступен для чтения!" >> "$OUTPUT_FILE"
    fi

    # Добавляем две пустые строки
    echo "" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
}

# --- Файлы в корне ---
add_section "flake.lock" "flake.lock"
add_section "flake.nix" "flake.nix"
add_section "hardware.nix" "hardware.nix"
add_section "hardware-configuration.nix" "hardware-configuration.nix"
add_section "lib.nix" "lib.nix"

# --- Скрипты (не .nix) ---
add_section "scripts/qmmp-wayland-fix" "scripts/qmmp-wayland-fix"
add_section "scripts/reaper" "scripts/reaper"

# --- pkgs/ ---
add_section "pkgs/default.nix" "pkgs/default.nix"
add_section "pkgs/minion.nix" "pkgs/minion.nix"
add_section "pkgs/parabolic.nix" "pkgs/parabolic.nix"

# --- overlays/ ---
add_section "overlays/default.nix" "overlays/default.nix"

# --- modules/ ---
add_section "modules/default.nix" "modules/default.nix"
add_section "modules/home.nix" "modules/home.nix"
add_section "modules/home-file.nix" "modules/home-file.nix"

add_section "modules/hx_git.nix" "modules/hx_git.nix"
add_section "modules/hx_kitty.nix" "modules/hx_kitty.nix"
add_section "modules/hx_music.nix" "modules/hx_music.nix"
add_section "modules/hx_obs.nix" "modules/hx_obs.nix"
add_section "modules/hx_plasma.nix" "modules/hx_plasma.nix"
add_section "modules/hx_zsh.nix" "modules/hx_zsh.nix"

add_section "modules/nx_configuration-kde_plasma.nix" "modules/nx_configuration-kde_plasma.nix"
add_section "modules/nx_firewall.nix" "modules/nx_firewall.nix"
add_section "modules/nx_locale.nix" "modules/nx_locale.nix"
add_section "modules/nx_optimization.nix" "modules/nx_optimization.nix"
add_section "modules/nx_pipewire.nix" "modules/nx_pipewire.nix"
add_section "modules/nx_sddm.nix" "modules/nx_sddm.nix"
add_section "modules/nx_steam.nix" "modules/nx_steam.nix"
add_section "modules/nx_thunar.nix" "modules/nx_thunar.nix"
add_section "modules/nx_users.nix" "modules/nx_users.nix"

# Удаляем лишние пустые строки в конце файла
sed -i '/^$/N;/^\n$/D' "$OUTPUT_FILE"

echo "Готово! Файл создан: $OUTPUT_FILE"
