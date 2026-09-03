# modules/nx_kate.nix
{ myLib, pkgs, ... }:

let
  dotfilesKate = "${myLib.home}/${myLib.configDirName}/dotfiles/config/kate";

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

  sessionTemplate = pkgs.writeText "anonymous.katesession" pluginsSection;
in
{
  system.activationScripts.kate-plugins = {
    supportsDryActivation = true;
    text = ''
      mkdir -p "${myLib.home}/.local/share/kate"
      cp "${sessionTemplate}" "${myLib.home}/.local/share/kate/anonymous.katesession"
      chown lucerno:lucerno "${myLib.home}/.local/share/kate/anonymous.katesession"
    '';
  };

  systemd.tmpfiles.rules = [
    "L+ ${myLib.home}/.config/katerc - lucerno lucerno - ${dotfilesKate}/katerc"
    "L+ ${myLib.home}/.config/kate-externaltoolspluginrc - lucerno lucerno - ${dotfilesKate}/kate-externaltoolspluginrc"
    "L+ ${myLib.home}/.config/katevirc - lucerno lucerno - ${dotfilesKate}/katevirc"
    "L+ ${myLib.home}/.config/kate - lucerno lucerno - ${dotfilesKate}/kate"
  ];
}
