#!/usr/bin/env bash

# Скрипт для генерации файла с содержимым конфигурации NixOS
# Путь: /home/lucerno/nixos-config/generate-prompt.sh

set -euo pipefail

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
add_section "mylib.nix" "mylib.nix"
# hardware-configuration.nix теперь находится в modules/nixos/, поэтому не включаем отдельно

# --- Пакеты (pkgs/) ---
echo "# --- Пакеты (pkgs/) ---" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"
while IFS= read -r file; do
    rel_path="${file#./}"
    add_section "$rel_path" "$file"
done < <(find pkgs -type f -name "*.nix" | sort)

# --- Модули (modules/) ---
echo "# --- Модули (modules/) ---" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"
while IFS= read -r file; do
    rel_path="${file#./}"
    add_section "$rel_path" "$file"
done < <(find modules -type f -name "*.nix" | sort)

# Удаляем лишние пустые строки в конце файла
sed -i '/^$/N;/^\n$/D' "$OUTPUT_FILE"

echo "Готово! Файл создан: $OUTPUT_FILE"
