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

    echo "$title" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"

    if [[ -f "$source_file" && -r "$source_file" ]]; then
        cat "$source_file" >> "$OUTPUT_FILE"
    else
        echo "# ОШИБКА: Файл $source_file не найден или недоступен для чтения!" >> "$OUTPUT_FILE"
    fi

    echo "" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
}

# --- Файлы в корне (перечисляем вручную) ---
add_section "flake.lock" "flake.lock"
add_section "flake.nix" "flake.nix"
add_section "hardware.nix" "hardware.nix"
add_section "hardware-configuration.nix" "hardware-configuration.nix"
add_section "lib.nix" "lib.nix"

# --- pkgs/ (автоматически все .nix файлы) ---
echo "# --- Пакеты (pkgs/) ---" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"
for file in $(find pkgs -maxdepth 1 -name "*.nix" | sort); do
    filename=$(basename "$file" .nix)
    add_section "pkgs/$filename.nix" "$file"
done

# --- overlays/ (автоматически все .nix файлы) ---
for file in $(find overlays -maxdepth 1 -name "*.nix" | sort); do
    filename=$(basename "$file" .nix)
    add_section "overlays/$filename.nix" "$file"
done

# --- modules/ (автоматически все .nix файлы) ---
for file in $(find modules -maxdepth 1 -name "*.nix" | sort); do
    filename=$(basename "$file" .nix)
    add_section "modules/$filename.nix" "$file"
done

# Удаляем лишние пустые строки в конце файла
sed -i '/^$/N;/^\n$/D' "$OUTPUT_FILE"

echo "Готово! Файл создан: $OUTPUT_FILE"
