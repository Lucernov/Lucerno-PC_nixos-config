# modules/nx_kate.nix
{ myLib, pkgs, ... }:

let
  # Содержимое секции [Kate Plugins] прямо здесь
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

  # Готовый файл сессии (только секция плагинов) для копирования
  sessionTemplate = pkgs.writeText "anonymous.katesession" pluginsSection;

  # Путь к остальным dotfiles (статичные конфиги) — используем относительный путь от модуля
  dotfilesKate = ../dotfiles/config/kate;
in
{
  systemd.tmpfiles.rules = [
    # Симлинки для статичных настроек Kate (не сессия)
    "L+ ${myLib.home}/.config/katerc - lucerno lucerno - ${dotfilesKate}/katerc"                                          # Основной файл конфигурации Kate
    "L+ ${myLib.home}/.config/kate-externaltoolspluginrc - lucerno lucerno - ${dotfilesKate}/kate-externaltoolspluginrc"  # Настройки плагина внешних инструментов (глобальные)
    "L+ ${myLib.home}/.config/katevirc - lucerno lucerno - ${dotfilesKate}/katevirc"                                      # Настройки Vi-режима
    "L+ ${myLib.home}/.config/kate - lucerno lucerno - ${dotfilesKate}/kate"                                              # Папка с внешними инструментами и LSP-клиентом (.config/kate/lspclient/settings.json)

    # Копируем шаблон сессии в домашнюю папку при каждой загрузке (тип 'C')
    "C ${myLib.home}/.local/share/kate/anonymous.katesession - lucerno lucerno - ${sessionTemplate}"
  ];
}
