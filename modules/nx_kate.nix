# modules/nx_kate.nix
{ myLib, pkgs, lib, ... }:

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
  '';

  sessionTemplate = pkgs.writeText "anonymous.katesession" pluginsSection;
  sessionFile = "${myLib.home}/.local/share/kate/anonymous.katesession";

  # Читаем флаг из myLib (по умолчанию false)
  autoUpdate = myLib.kate.autoUpdateSession or false;
in
{
  # Если флаг включён — заменяем файл сессии при каждой активации
  system.activationScripts.kate-plugins = lib.mkIf autoUpdate {
    supportsDryActivation = true;
    text = ''
      mkdir -p "${myLib.home}/.local/share/kate"
      cp "${sessionTemplate}" "${sessionFile}"
      chown lucerno:lucerno "${sessionFile}"
      echo "✅ Kate session set to default plugins (auto-update enabled)."
    '';
  };

  # ====== Симлинки для статичных настроек ======
  systemd.tmpfiles.rules = [
    "L+ ${myLib.home}/.config/katerc - lucerno lucerno - ${dotfilesKate}/katerc"                                          # Основной файл конфигурации Kate
    "L+ ${myLib.home}/.config/kate-externaltoolspluginrc - lucerno lucerno - ${dotfilesKate}/kate-externaltoolspluginrc"  # Настройки плагина внешних инструментов (глобальные)
    "L+ ${myLib.home}/.config/katevirc - lucerno lucerno - ${dotfilesKate}/katevirc"                                      # Настройки Vi-режима
    "L+ ${myLib.home}/.config/kate - lucerno lucerno - ${dotfilesKate}/kate"                                              # Папка с внешними инструментами и LSP-клиентом (.config/kate/lspclient/settings.json)
  ];
}
