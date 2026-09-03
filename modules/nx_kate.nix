# modules/nx_kate.nix
{ myLib, ... }:

let

  dotfilesKate = "${myLib.home}/${myLib.configDirName}/dotfiles/config/kate";                                             # Корень ваших dotfiles для Kate
in
{
  systemd.tmpfiles.rules = [                                                                                              # Симлинки для настроек Kate
    "L+ ${myLib.home}/.config/katerc - lucerno lucerno - ${dotfilesKate}/katerc"                                          # Основной файл конфигурации Kate
    "L+ ${myLib.home}/.config/kate-externaltoolspluginrc - lucerno lucerno - ${dotfilesKate}/kate-externaltoolspluginrc"  # Настройки плагина внешних инструментов (глобальные)
    "L+ ${myLib.home}/.config/katevirc - lucerno lucerno - ${dotfilesKate}/katevirc"                                      # Настройки Vi-режима
    "L+ ${myLib.home}/.config/kate - lucerno lucerno - ${dotfilesKate}/kate"                                              # Папка с внешними инструментами и настройки LSP-клиента .config/kate/lspclient/settings.json
  ];
}
