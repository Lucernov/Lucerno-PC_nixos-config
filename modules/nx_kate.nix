# modules/nx_kate.nix
{ myLib, pkgs, ... }:

let
  # Абсолютный путь к папке с конфигами Kate в вашем репозитории
  dotfilesKate = "${myLib.home}/${myLib.configDirName}/dotfiles/config/kate";

  # Секция [Kate Plugins] прямо в коде (без внешнего файла)
  pluginsSection = ''
    [Kate Plugins]
    bookmarksplugin=false
    cmaketoolsplugin=false
    compilerexplorer=false
    eslintplugin=false
    externaltoolsplugin=true
    formatplugin=false
    katebacktracebrowserplugin=false
    katebuildplugin=false
    katecloseexceptplugin=false
    katecolorpickerplugin=false
    katectagsplugin=false
    katefilebrowserplugin=false
    katefiletreeplugin=true
    kategdbplugin=false
    kategitblameplugin=false
    katekonsoleplugin=true
    kateprojectplugin=true
    katereplicodeplugin=false
    katesearchplugin=true
    katesnippetsplugin=false
    katesqlplugin=false
    katesymbolviewerplugin=false
    katexmlcheckplugin=false
    katexmltoolsplugin=false
    keyboardmacrosplugin=false
    ktexteditorpreviewplugin=false
    latexcompletionplugin=false
    lspclientplugin=true
    openlinkplugin=false
    rainbowparens=false
    rbqlplugin=false
    tabswitcherplugin=true
    templateplugin=false
    textfilterplugin=true
    # проверка
  '';

  # Готовый файл сессии в Nix store (только секция плагинов)
  sessionTemplate = pkgs.writeText "anonymous.katesession" pluginsSection;
in
{
  systemd.tmpfiles.rules = [
    # Симлинки для статичных настроек — используем абсолютные пути к файлам в репозитории
    "L+ ${myLib.home}/.config/katerc - lucerno lucerno - ${dotfilesKate}/katerc"                                          # Основной файл конфигурации Kate
    "L+ ${myLib.home}/.config/kate-externaltoolspluginrc - lucerno lucerno - ${dotfilesKate}/kate-externaltoolspluginrc"  # Настройки плагина внешних инструментов (глобальные)
    "L+ ${myLib.home}/.config/katevirc - lucerno lucerno - ${dotfilesKate}/katevirc"                                      # Настройки Vi-режима
    "L+ ${myLib.home}/.config/kate - lucerno lucerno - ${dotfilesKate}/kate"                                              # Папка с внешними инструментами и LSP-клиентом (.config/kate/lspclient/settings.json)

    # Копируем шаблон сессии из store в домашнюю папку при загрузке (тип 'C')
    "C ${myLib.home}/.local/share/kate/anonymous.katesession - lucerno lucerno - ${sessionTemplate}"
  ];
}
