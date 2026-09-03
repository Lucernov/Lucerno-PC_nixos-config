# modules/nx_kate.nix
{ myLib, pkgs, ... }:

let
  dotfilesKate = "${myLib.home}/${myLib.configDirName}/dotfiles/config/kate";                                             # Корень ваших dotfiles для Kate
  pluginsTemplate = "${dotfilesKate}/kate-plugins.ini";                                                                   # Файл-шаблон с настройками плагинов (секция [Kate Plugins])
  sessionFile = "${myLib.home}/.local/share/kate/anonymous.katesession";                                                  # Путь к файлу анонимной сессии

  # Полные пути к утилитам, чтобы они были доступны в активационном скрипте
  coreutilsBin = "${pkgs.coreutils}/bin";
  sedBin = "${pkgs.sed}/bin";
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
      ${coreutilsBin}/mkdir -p "${myLib.home}/.local/share/kate"

      # Если файла сессии нет, просто копируем шаблон
      if [ ! -f "${sessionFile}" ]; then
        ${coreutilsBin}/cp "${pluginsTemplate}" "${sessionFile}"
        ${coreutilsBin}/chown lucerno:lucerno "${sessionFile}"
      else
        # Иначе заменяем существующую секцию [Kate Plugins]
        tmpfile=$(${coreutilsBin}/mktemp)
        # Проверяем, есть ли секция в файле
        if ${sedBin}/sed -n '/^\[Kate Plugins\]/q0; q1' "${sessionFile}" 2>/dev/null; then
          # Копируем всё до секции [Kate Plugins] (не включая её)
          ${sedBin}/sed -n '1,/^\[Kate Plugins\]/p' "${sessionFile}" | ${sedBin}/sed '$d' > "$tmpfile"
          # Добавляем новую секцию из шаблона
          ${coreutilsBin}/cat "${pluginsTemplate}" >> "$tmpfile"
          # Добавляем всё, что после секции (до следующей секции или до конца файла)
          ${sedBin}/sed -n '/^\[Kate Plugins\]/,/^\[/p' "${sessionFile}" | ${coreutilsBin}/tail -n +2 | ${sedBin}/sed -n '/^\[/,$p' >> "$tmpfile"
        else
          # Если секции нет, просто дописываем шаблон в конец
          ${coreutilsBin}/cat "${sessionFile}" > "$tmpfile"
          ${coreutilsBin}/echo "" >> "$tmpfile"
          ${coreutilsBin}/cat "${pluginsTemplate}" >> "$tmpfile"
        fi
        # Заменяем оригинал
        ${coreutilsBin}/mv "$tmpfile" "${sessionFile}"
        # Устанавливаем правильного владельца, чтобы Kate мог перезаписывать файл
        ${coreutilsBin}/chown lucerno:lucerno "${sessionFile}"
      fi
    '';
  };
}
