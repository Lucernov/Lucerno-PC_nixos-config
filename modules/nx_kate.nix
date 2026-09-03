# modules/nx_kate.nix
{ myLib, pkgs, ... }:

let
  dotfilesKate = "${myLib.home}/${myLib.configDirName}/dotfiles/config/kate";
  # Берём шаблон плагинов и добавляем к нему заголовок, чтобы получился полноценный файл сессии
  sessionTemplate = pkgs.writeText "anonymous.katesession" ''
    [Kate Plugins]
    ${builtins.readFile "${dotfilesKate}/kate-plugins.ini"}
  '';
in
{
  systemd.tmpfiles.rules = [
    # Симлинки для статичных настроек
    "L+ ${myLib.home}/.config/katerc - lucerno lucerno - ${dotfilesKate}/katerc"                                          # Основной файл конфигурации Kate
    "L+ ${myLib.home}/.config/kate-externaltoolspluginrc - lucerno lucerno - ${dotfilesKate}/kate-externaltoolspluginrc"  # Настройки плагина внешних инструментов (глобальные)
    "L+ ${myLib.home}/.config/katevirc - lucerno lucerno - ${dotfilesKate}/katevirc"                                      # Настройки Vi-режима
    "L+ ${myLib.home}/.config/kate - lucerno lucerno - ${dotfilesKate}/kate"                                              # Папка с внешними инструментами и LSP-клиентом (.config/kate/lspclient/settings.json)

    # Копируем (а не линкуем!) шаблон сессии в нужное место
    # Тип 'L+' создаёт симлинк, 'C' копирует файл при загрузке. Используем 'C' для копирования.
    "C ${myLib.home}/.local/share/kate/anonymous.katesession - lucerno lucerno - ${sessionTemplate}"
  ];
}
