{ myLib, ... }:

let
  dotfilesKate = "${myLib.home}/${myLib.configDirName}/dotfiles/config/kate";                                             # Корень ваших dotfiles для Kate
  pluginsTemplate = "${dotfilesKate}/kate-plugins.ini";                                                                   # Файл-шаблон с настройками плагинов (секция [Kate Plugins])
  sessionFile = "${myLib.home}/.local/share/kate/anonymous.katesession";                                                  # Путь к файлу анонимной сессии
in
{
  # Симлинки для статичных настроек Kate (не сессия)
  systemd.tmpfiles.rules = [
    "L+ ${myLib.home}/.config/katerc - lucerno lucerno - ${dotfilesKate}/katerc"                                          # Основной файл конфигурации Kate
    "L+ ${myLib.home}/.config/kate-externaltoolspluginrc - lucerno lucerno - ${dotfilesKate}/kate-externaltoolspluginrc"  # Настройки плагина внешних инструментов (глобальные)
    "L+ ${myLib.home}/.config/katevirc - lucerno lucerno - ${dotfilesKate}/katevirc"                                      # Настройки Vi-режима
    "L+ ${myLib.home}/.config/kate - lucerno lucerno - ${dotfilesKate}/kate"                                              # Папка с внешними инструментами и LSP-клиентом (.config/kate/lspclient/settings.json)
  ];

  # Скрипт активации, который обновляет секцию [Kate Plugins] в файле сессии
  system.activationScripts.kate-plugins = {
    supportsDryActivation = true;
    text = ''
      # Убедимся, что папка для сессии существует
      mkdir -p "${myLib.home}/.local/share/kate"

      # Если файла сессии нет, просто копируем шаблон
      if [ ! -f "${sessionFile}" ]; then
        cp "${pluginsTemplate}" "${sessionFile}"
        chown lucerno:lucerno "${sessionFile}"
      else
        # Иначе заменяем существующую секцию [Kate Plugins]
        tmpfile=$(mktemp)
        # Проверяем, есть ли секция в файле
        if grep -q "^\[Kate Plugins\]" "${sessionFile}"; then
          # Копируем всё до секции [Kate Plugins] (не включая её)
          sed -n '1,/^\[Kate Plugins\]/p' "${sessionFile}" | sed '$d' > "$tmpfile"
          # Добавляем новую секцию из шаблона
          cat "${pluginsTemplate}" >> "$tmpfile"
          # Добавляем всё, что после секции (до следующей секции или до конца файла)
          sed -n '/^\[Kate Plugins\]/,/^\[/p' "${sessionFile}" | tail -n +2 | sed -n '/^\[/,$p' >> "$tmpfile"
        else
          # Если секции нет, просто дописываем шаблон в конец
          cat "${sessionFile}" > "$tmpfile"
          echo "" >> "$tmpfile"
          cat "${pluginsTemplate}" >> "$tmpfile"
        fi
        # Заменяем оригинал
        mv "$tmpfile" "${sessionFile}"
        # Устанавливаем правильного владельца, чтобы Kate мог перезаписывать файл
        chown lucerno:lucerno "${sessionFile}"
      fi
    '';
  };
}
