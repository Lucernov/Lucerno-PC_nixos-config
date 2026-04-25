#!/usr/bin/env bash

# Скрипт для генерации файла с содержимым конфигурации NixOS
# Путь: /home/lucerno/nixos-config/generate-prompt.sh

# Переходим в директорию скрипта
cd "$(dirname "$0")" || exit 1

# Выходной файл
OUTPUT_FILE="Promt(Lucerno-PC).txt"

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
    
    # Добавляем содержимое файла, если он существует
    if [[ -f "$source_file" ]]; then
        cat "$source_file" >> "$OUTPUT_FILE"
    else
        echo "# ОШИБКА: Файл $source_file не найден!" >> "$OUTPUT_FILE"
    fi
    
    # Добавляем два пустых отступа (две пустые строки)
    echo "" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
}

# 1-3: flake.nix
add_section "flake.nix" "flake.nix"

# 4-5: configuration.nix
add_section "configuration.nix" "configuration.nix"

# 6-7: home.nix
add_section "home.nix" "home.nix"

# 8-9: hardware-configuration.nix
add_section "hardware-configuration.nix" "hardware-configuration.nix"

# Удаляем последние две пустые строки (чтобы не было лишних отступов в конце файла)
# Но если хотите оставить их - закомментируйте следующую строку
sed -i '/^$/N;/^\n$/D' "$OUTPUT_FILE"

echo "Готово! Файл создан: $(pwd)/$OUTPUT_FILE"
