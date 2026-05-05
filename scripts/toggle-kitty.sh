#!/run/current-system/sw/bin/bash

# Ищем окно Kitty, которое запущено с идентификатором "quick-access"
# Можно использовать class или title. Удобнее по классу, который мы сами зададим.
if kitty @ ls 2>/dev/null | grep -q "quick-access"; then
    # Если окно существует, закрываем его
    kitty @ close-window --match title:"quick-access"
else
    # Иначе запускаем новое окно в выпадающем режиме
    kitten quick-access-terminal
fi
